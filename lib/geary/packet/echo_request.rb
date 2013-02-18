require_relative 'request'

module Geary
  module Packet
    class EchoRequest < Request

      def self.type
        16
      end

      def self.packet_name
        'ECHO_REQ'
      end

      def data
        arguments.first
      end

    end
  end
end
