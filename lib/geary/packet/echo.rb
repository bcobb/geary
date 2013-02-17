require_relative 'response'

module Geary
  module Packet
    class Echo < Response

      def data
        arguments.first
      end

    end
  end
end
