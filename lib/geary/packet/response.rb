require 'virtus'

module Geary
  module Packet
    class Response
      include Virtus::ValueObject

      attribute :arguments, Array[String]
    end
  end
end
