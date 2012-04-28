module Gearman
  class Client

    def initialize
      @stream = Stream.new(::TCPSocket.new('localhost', '4730'))
    end

    def echo(data)
      # request
      request = "\0REQ" + [16, data.size].pack('NN') + data
      @stream.write(request)

      # response
      header = @stream.read(12)
      magic, type, length = header.unpack('a4NN')
      @stream.read(length)
    end

  end
end
