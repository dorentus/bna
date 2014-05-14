module Bnet
  # The Battle.net authenticator
  class Authenticator
    # @!attribute [r] serial
    # @return [String] serial
    attr_reader :serial

    # @!attribute [r] secret
    # @return [String] hexlified secret
    attr_reader :secret

    # @!attribute [r] restorecode
    # @return [String] restoration code
    attr_reader :restorecode

    # @!attribute [r] region
    # @return [Symbol] region
    attr_reader :region

    # Create a new authenticator with given serial and secret
    # @param serial [String]
    # @param secret [String]
    def initialize(serial, secret)
      serial = Bnet::Attributes::Serial.new serial
      secret = Bnet::Attributes::Secret.new secret
      restorecode = Bnet::Attributes::Restorecode.new serial, secret

      @serial = serial.to_s
      @secret = secret.to_s
      @restorecode = restorecode.to_s
      @region = serial.region
    end

    # Request a new authenticator from server
    # @param region [Symbol]
    # @return [Bnet::Authenticator]
    def self.request_authenticator(region)
      k = create_one_time_pad(37)

      text = "\1#{k}#{region}#{CLIENT_MODEL}".left_fix_to(56, pad_string: "\0")
      e = rsa_encrypt_bin(text)

      response_body = request_for('new serial',
                                  region,
                                  ENROLLMENT_REQUEST_PATH,
                                  e)

      decrypted = decrypt_response(response_body.substring_at(8, length: 37), k)

      Authenticator.new(decrypted.substring_at(20, length: 17), decrypted.substring_at(0, length: 20))
    end

    # Restore an authenticator from server
    # @param serial [String]
    # @param restorecode [String]
    # @return [Bnet::Authenticator]
    def self.restore_authenticator(serial, restorecode)
      serial = Bnet::Attributes::Serial.new serial
      restorecode = Bnet::Attributes::Restorecode.new restorecode

      # stage 1
      challenge = request_for('restore (stage 1)',
                              serial.region,
                              RESTORE_INIT_REQUEST_PATH,
                              serial.normalized)

      # stage 2
      key = create_one_time_pad(20)

      digest = hmac_sha1_digest(serial.normalized + challenge, restorecode.binary)

      response_body = request_for('restore (stage 2)',
                                  serial.region,
                                  RESTORE_VALIDATE_REQUEST_PATH,
                                  serial.normalized + rsa_encrypt_bin(digest + key))

      Authenticator.new(serial, decrypt_response(response_body, key))
    end

    # Get server's time
    # @param region [Symbol]
    # @return [Integer] server timestamp in seconds
    def self.request_server_time(region)
      server_time_be = request_for('server time', region, TIME_REQUEST_PATH)
      server_time_be.reverse.unpack('Q')[0].to_f / 1000
    end

    # Get token from given secret and timestamp
    # @param secret [String] hexified secret
    # @param timestamp [Integer] UNIX timestamp in seconds,
    #   defaults to current time
    # @return [String, Integer] token and the next timestamp token to change
    def self.get_token(secret, timestamp = nil)
      secret = Bnet::Attributes::Secret.new secret

      current = (timestamp || Time.now.getutc.to_i) / 30

      digest = hmac_sha1_digest([current].pack('Q').reverse, secret.binary)

      start_position = digest.char_code_at(19) & 0xf

      token = digest.substring_at(start_position, length: 4).reverse.unpack('L')[0] & 0x7fffffff

      [sprintf('%08d', token % 1_0000_0000), (current + 1) * 30]
    end

    # Get authenticator's token from given timestamp
    # @param timestamp [Integer] UNIX timestamp in seconds,
    #   defaults to current time
    # @return [String, Integer] token and the next timestamp token to change
    def get_token(timestamp = nil)
      self.class.get_token(secret, timestamp)
    end

    # Get progress
    # @param timestamp [Float] UNIX timestamp in seconds,
    #   defaults to current time
    # @return Float progress in range (0.0 .. 1.0)
    def self.get_progress(timestamp = nil)
      timestamp ||= Time.now.getutc.to_f
      next_timestamp = (timestamp.to_i / 30 + 1) * 30.0
      1.0 - (next_timestamp - timestamp) / 30.0
    end

    # Hash representation of this authenticator
    # @return [Hash]
    def to_hash
      {
        serial: serial,
        secret: secret,
        restorecode: restorecode,
        region: region
      }
    end

    # String representation of this authenticator
    # @return [String]
    def to_s
      to_hash.to_s
    end

    # class methods
    class << self
      def create_one_time_pad(length)
        (0..1.0 / 0.0).reduce('') do |memo, _|
          break memo if memo.length >= length
          memo << rand.to_s.to_data.SHA1HexDigest
        end[0, length]
      end

      def decrypt_response(text, key)
        text.bytes.zip(key.bytes.to_a).reduce('') do |memo, pair|
          memo + (pair[0] ^ pair[1]).chr
        end
      end

      def rsa_encrypt_bin(bin)
        i = bin.unpack('C*').map { |x| x.to_s(16).rjust(2, '0') }.join.to_i(16)
        (i**RSA_KEY % RSA_MOD).to_s(16).scan(/.{2}/).map do |s|
          s.to_i(16)
        end.pack('C*')
      end

      def hmac_sha1_digest(text, key)
        text.to_data.HMACSHA1DigestWithKey(key.to_data).to_str
      end

      def request_for(label, region, path, body = nil)
        raise BadInputError, "bad region #{region}" unless AUTHENTICATOR_HOSTS.has_key? region

        url = NSURL.URLWithString "http://#{AUTHENTICATOR_HOSTS[region]}#{path}"
        request = NSMutableURLRequest.requestWithURL(url)
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        if body
          request.HTTPMethod = "POST"
          request.HTTPBody = body.to_data
        end

        responsePtr = Pointer.new :object
        errorPtr = Pointer.new :object
        responseData = NSURLConnection.sendSynchronousRequest(
          request,
          returningResponse: responsePtr,
          error: errorPtr
        )

        if responsePtr.value.nil? || responsePtr.value.statusCode != 200
          raise RequestFailedError, "Error requesting #{label}: [#{responsePtr.value.nil? ? "" : responsePtr.value.statusCode}]"
        end

        responseData.to_str
      end
    end
  end
end
