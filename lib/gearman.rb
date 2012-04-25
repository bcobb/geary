require 'timeout'

module Gearman
  class Client

    PACK = 'NN'
    UNPACK = 'a4NN'

    def echo(data)
      echo_req_packet_type = 16
      echo_req_packet_magic = "\0REQ"
      echo_req_packet_meta = [echo_req_packet_type, data.size].pack(PACK)
      echo_req_packet = [
        echo_req_packet_magic,
        echo_req_packet_meta,
        data
      ].join

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
          write_socket.write(echo_req_packet)
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
