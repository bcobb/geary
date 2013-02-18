require 'virtus'

module Geary
  module Packet
    class Standard
      include Virtus::ValueObject

      attribute :arguments, Array[String]

    end
  end
end
