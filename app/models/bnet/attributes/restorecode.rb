module Bnet
  module Attributes
    class Restorecode
      attr_reader :text

      def initialize(serial_or_restorecode, secret = nil)
        if secret.nil?
          restorecode = serial_or_restorecode.upcase
          raise BadInputError, "bad restoration code #{restorecode}" unless restorecode =~ /[0-9A-Z]{10}/
          @text = restorecode
        else
          serial = serial_or_restorecode.is_a?(Serial) ? serial_or_restorecode : Serial.new(serial_or_restorecode)
          secret = Secret.new secret unless secret.is_a?(Secret)

          bin = (serial.normalized + secret.binary).to_data.SHA1Digest.to_str

          @text = bin.bytes.to_a.last(10).map do |v|
            RESTORECODE_MAP[v & 0x1f]
          end.pack('C*')
        end
      end

      def binary
        text.bytes.map do |c|
          RESTORECODE_MAP_INVERSE[c]
        end.pack('C*')
      end

      alias_method :to_s, :text
    end
  end
end
