require 'timeout'

module Gearman
  class Client

    PACK = 'NN'
    MAGIC = "\0REQ"

    def echo(data)
      packet_type = 16
      packet_meta = [packet_type, data.size].pack(PACK)

      request = [MAGIC, packet_meta, data].join

      begin
        socket = TCPSocket.new('localhost', '4730')
      rescue => e
        abort 'Could not open connection to gearman server'
      end

      begin
        _, write_select = IO::select([], [socket])
        if write_socket = write_select[0]
          write_socket.write(request)
        end

        ReadsGearmanMessages.from(socket)
      ensure
        socket.close
      end
    end

  end

  class ReadsGearmanMessages

    UNPACK = 'a4NN'

    attr_reader :body

    def self.from(socket)
      reader = new(socket)
      reader.read
      reader.body
    end

    def initialize(socket)
      @socket = socket
      @header = ''
      @body = ''
    end

    def read(header_length = 12)
      until @header.size == header_length do
        read_select, _ = IO::select([@socket])
        if read_socket = read_select[0]
          @header << read_socket.readpartial(header_length - @header.size)
        end
      end

      magic, type, body_length = @header.unpack(UNPACK)

      until @body.size == body_length do
        read_select, _ = IO::select([@socket])
        if read_socket = read_select[0]
          @body << read_socket.readpartial(body_length - @body.size)
        end
      end
    end

  end

end
