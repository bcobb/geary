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

      socket = TCPSocket.new('localhost', '4730')
      header = ''
      body = ''

      begin
        Timeout::timeout(10) do
          socket.write(echo_req_packet)

          while header.size < 12 do
            IO::select([socket]) or break
            header += socket.readpartial(12 - header.size)
          end

          magic, type, size = header.unpack(UNPACK)

          while body.size < size do
            IO::select([socket]) or break
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
