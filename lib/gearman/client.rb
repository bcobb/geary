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

    def submit_job(function_name, job_id, data)
      arguments = [function_name, job_id, data].join("\0")
      request = "\0REQ" + [7, arguments.size].pack('NN') + arguments
      @stream.write(request)

      header = @stream.read(12)
      magic, type, length = header.unpack('a4NN')
      @stream.read(length)
    end

  end
end
