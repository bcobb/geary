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

      readers, _ = IO.select([socket])
      header = readers.first.read(12).unpack('a4NN')
      magic, type, message_length = header

      readers, _ = IO.select([socket])
      response = readers.first.read(message_length)

      if block_given?
        yield response
      end
    end

  end
end
