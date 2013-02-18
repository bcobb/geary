require 'virtus'

module Geary
  module Packet
    class Response
      include Virtus::ValueObject

      attribute :arguments, Array[String]

      def magic
        "\0RES"
      end

      def type
        self.class.type
      end

    end
  end
end
