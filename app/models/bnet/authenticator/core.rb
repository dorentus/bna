#require 'net/http'
#require 'digest/sha1'

module Bnet

  class Authenticator

    class << self

      def create_one_time_pad(length)
        (0..1.0/0.0).reduce('') do |memo, i|
          break memo if memo.length >= length
          memo << rand().to_s.to_data.SHA1HexDigest
        end[0, length]
      end

      def decrypt_response(text, key)
        text.bytes.zip(key.bytes.to_a).reduce('') do |memo, pair|
          memo + (pair[0] ^ pair[1]).chr
        end
      end

      def rsa_encrypt_bin(bin)
        i = bin.unpack('C*').map{ |i| i.to_s(16).rjust(2, '0') }.join.to_i(16)
        (i ** RSA_KEY % RSA_MOD).to_s(16).scan(/.{2}/).map {|s| s.to_i(16)}.pack('C*')
      end

      def request_for(label, region, path, body = nil)
        raise BadInputError.new("bad region #{region}") unless AUTHENTICATOR_HOSTS.has_key? region

        url = NSURL.URLWithString "http://#{AUTHENTICATOR_HOSTS[region]}#{path}"
        request = NSMutableURLRequest.requestWithURL(url)
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        if ! body.nil?
          request.HTTPMethod = "POST"
          request.HTTPBody = body.to_data
        end

        responsePtr = Pointer.new :object
        errorPtr = Pointer.new :object
        responseData = NSURLConnection.sendSynchronousRequest(request, returningResponse: responsePtr, error: errorPtr)

        if responsePtr.value.nil? || responsePtr.value.statusCode != 200
          raise RequestFailedError.new("Error requesting #{label}: [#{responsePtr.value.nil? ? "" : responsePtr.value.statusCode}]", errorPtr.value)
        end

        responseData.to_str
      end

    end

  end

end
