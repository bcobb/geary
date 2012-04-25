require 'timeout'

module Gearman
  class Client

    PACK = 'NN'
    UNPACK = 'a4NN'
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

      header = ''
      body = ''

      begin
        _, write_select = IO::select([], [socket])
        if write_socket = write_select[0]
          write_socket.write(request)
        end

        while header.size < 12 do
          read_select, _ = IO::select([socket])
          if read_socket = read_select[0]
            header += read_socket.readpartial(12)
          end
        end

        magic, type, size = header.unpack(UNPACK)

        while body.size < size do
          read_select, _ = IO::select([socket])
          if read_socket = read_select[0]
            body += socket.readpartial(size - body.size)
          end
        end
      ensure
        socket.close
      end

      body
    end

  end

end
