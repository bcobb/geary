module Gearman
  class Packet

    PACKING = 'a4NN'

    def self.load(socket)
      magic, type, body_length = socket.read(12).unpack(PACKING)
      arguments = socket.read(body_length).split("\0")

      new(magic, type, arguments)
    end

    def self.dump(packet)
      body = packet[:arguments].join("\0")
      header = [packet[:magic], packet[:type], body.length].pack(PACKING)

      header + body
    end

    attr_reader :magic, :type, :arguments

    def initialize(magic, type, arguments)
      @magic = magic
      @type = type
      @arguments = arguments
    end

    def request?
      @magic == "\0REQ"
    end

    def response?
      @magic == "\0RES"
    end

    def [](attr)
      send attr
    end

  end
end
