module Gearman
  class Packet

    HEADER_PACKING = 'a4NN'
    NULL_BYTE = "\0"

    def self.load(socket)
      magic, type, body_length = socket.read(12).unpack(HEADER_PACKING)
      arguments = socket.read(body_length).split(NULL_BYTE)

      new(magic, type, arguments)
    end

    def self.dump(packet)
      body = packet[:arguments].join(NULL_BYTE)
      header = [packet[:magic], packet[:type], body.length].pack(HEADER_PACKING)

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
