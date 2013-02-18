require_relative 'response'

module Geary
  module Packet
    class Error < Response

      def self.type
        19
      end

      def self.packet_name
        'ERROR'
      end

      def error_code
        arguments.first
      end

      def error_text
        arguments[1]
      end

    end
  end
end
