module Gearman
  class Request

    MAGIC = "\0REQ"

    def initialize(type, *arguments)
      @packet = Packet.new MAGIC, type, arguments
    end

    def to_s
      Packet.dump(@packet)
    end

    def ==(request)
      request.to_s == to_s
    end

  end
end
