require_relative 'response'

module Geary
  module Packet
    class EchoResponse < Response

      def self.type
        17
      end

      def self.packet_name
        'ECHO_RES'
      end

      def data
        arguments.first
      end

    end
  end
end
