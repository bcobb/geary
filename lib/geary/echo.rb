module Geary
  class Echo

    attr_reader :socket

    def initialize(socket)
      @socket = socket
    end

    def call(data)
      body = [data].join("\0")
      header = ["\0REQ", 16, body.size].pack('a4NN')

      _, writers = IO.select([], [socket])
      writers.first.write(header + body)

      magic, type, message_length = read(12).unpack('a4NN')
      response = read(message_length)

      if block_given?
        yield response
      end
    end

    def read(length)
      readers, _ = IO.select([socket])
      readers.first.read(length)
    end

  end
end
