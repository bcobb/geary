module Geary
  class PacketTranslator

    def translate(magic, type, arguments = nil)
      if type == 17
        packet_type = Packet::Echo
      else
        packet_type = Packet::Error
      end

      packet_type.new(:arguments => Array(arguments))
    end

  end
end
