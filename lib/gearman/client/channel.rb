require 'socket'

module Gearman
  module Client
    class Channel

      def initialize(server_address)
        @server_address = server_address
      end

      def submit_job_bg(function_name, data = '')
        host, port = @server_address.split(':')
        socket = TCPSocket.new(host, port)

        unique_id_start = Time.now.to_f.to_s.gsub('.', '')
        unique_id = "#{unique_id_start}#{rand(10000)}"

        magic = "\0REQ"
        type = 18
        arguments = [function_name, unique_id, data]

        body = arguments.join("\0")
        header = [magic, type, body.size].pack('a4NN')

        IO.select([], [socket])
        socket.write(header + body)
      end

    end
  end
end
