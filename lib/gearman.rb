require 'timeout'

module Gearman
  class Client

    PACK = 'NN'
    MAGIC = "\0REQ"

    def echo(data)
      packet_type = 16
      packet_meta = [packet_type, data.length].pack(PACK)

      data = [MAGIC, packet_meta, data].join

      socket = Socket.new('localhost', '4730')
      server = Server.new(socket)

      begin
        server.request(data)
      ensure
        socket.close
      end
    end

  end

  class Socket

    def initialize(server, port)
      begin
        @socket = ::TCPSocket.new(server, port)
      rescue => e
        abort 'Could not open connection to gearman server'
      end
    end

    def write(data)
      _, write_select = ::IO::select([], [@socket])
      if write_socket = write_select[0]
        write_socket.write(data)
      end
    end

    def read(length)
      response = ''
      until response.length == length do
        read_select, _ = ::IO::select([@socket])
        if read_socket = read_select[0]
          response << read_socket.readpartial(length - response.length)
        end
      end
      response
    end

    def close
      @socket.close
    end

  end

  class Server

    MAGIC_TYPE_LENGTH = 'a4NN'

    def initialize(socket)
      @socket = socket
    end

    def request(data)
      @socket.write data

      response_body
    end

    private

    def response_body
      @socket.read(response_headers.last)
    end

    def response_headers
      @socket.read(12).unpack(MAGIC_TYPE_LENGTH)
    end

  end

end
