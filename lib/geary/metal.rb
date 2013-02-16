module Geary
  class Metal

    def echo_req(data, socket)
      body = [data].join("\0")
      header = ["\0REQ", 16, body.size].pack('a4NN')

      _, writers = IO.select([], [socket])
      writers.first.write(header + body)
    end

    def echo_res(socket)
      readers, _ = IO.select([socket])
      header = readers.first.read(12).unpack('a4NN')
      magic, type, message_length = header

      readers, _ = IO.select([socket])
      readers.first.read(message_length)
    end

  end
end
