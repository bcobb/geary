require 'virtus'

module Geary
  module Packet
    class Request
      include Virtus::ValueObject

      attribute :arguments, Array[String]

      def magic
        "\0REQ"
      end

      def type
        self.class.type
      end

    end
  end
end
