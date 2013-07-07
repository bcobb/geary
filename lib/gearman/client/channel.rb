require 'socket'
require 'securerandom'

module Gearman
  module Client
    class Channel

      attr_reader :generate_unique_id

      def initialize(server_address)
        @server_address = server_address
        @generate_unique_id = SecureRandom.method(:uuid)
      end

      def submit_job_bg(function_name, data = '')
        host, port = @server_address.split(':')
        socket = TCPSocket.new(host, port)

        magic = "\0REQ"
        type = 18
        arguments = [function_name, generate_unique_id.(), data]

        body = arguments.join("\0")
        header = [magic, type, body.size].pack('a4NN')

        IO.select([], [socket])
        socket.write(header + body)
      end

    end
  end
end
