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

      text = "\1" + k + region.to_s + CLIENT_MODEL.ljust(16, "\0")[0, 16]
      e = rsa_encrypt_bin(text)

      response_body = request_for('new serial',
                                  region,
                                  ENROLLMENT_REQUEST_PATH,
                                  e)

      decrypted = decrypt_response(response_body[8, 37], k)

      Authenticator.new(decrypted[20, 17], decrypted[0, 20])
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

      digest = (serial.normalized + challenge).to_data
                .HMACSHA1DigestWithKey(restorecode.binary.to_data).to_str

      payload = serial.normalized + rsa_encrypt_bin(digest + key)

      response_body = request_for('restore (stage 2)',
                                  serial.region,
                                  RESTORE_VALIDATE_REQUEST_PATH,
                                  payload)

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

      digest = [current].pack('Q').reverse.to_data
                                  .HMACSHA1DigestWithKey(secret.binary.to_data)
                                  .to_str

      start_position = digest.each_char.take(20).last.bytes.first & 0xf

      token = digest[start_position, 4].reverse.unpack('L')[0] & 0x7fffffff

      [sprintf('%08d', token % 1_0000_0000), (current + 1) * 30]
    end

    # Get authenticator's token from given timestamp
    # @param timestamp [Integer] UNIX timestamp in seconds,
    #   defaults to current time
    # @return [String, Integer] token and the next timestamp token to change
    def get_token(timestamp = nil)
      self.class.get_token(secret, timestamp)
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
  end
end
