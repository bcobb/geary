require 'socket'
require 'timeout'

module Geary
  class CLI

    TmpError = Class.new(RuntimeError)

    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR,
                   kernel=Kernel)
      @argv = argv
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
      @kernel = kernel
    end

    def execute!
      begin
        Timeout.timeout(1, TmpError) do
          socket = TCPSocket.new('localhost', 4730)

          write_to(socket) do
            can_do_body = ['Geary.default'].join("\0")
            can_do_header = ["\0REQ", 1, can_do_body.size].pack('a4NN')

            can_do_header + can_do_body
          end

          write_to(socket) do
            grab_job_body = [].join("\0")
            grab_job_header = ["\0REQ", 9, grab_job_body.size].pack('a4NN')

            grab_job_header + grab_job_body
          end

          read_from(socket) do |packet|
            if packet[:type] == 11
              payload = JSON.load(packet[:arguments].last)
              class_name = payload['class']
              require class_name.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
              klass = Object.const_get(class_name)
              worker = klass.new
              worker.perform(*payload['args'])
            end
          end
        end
      rescue TmpError
        @stderr.puts "Out of time"
        @kernel.exit(1)
      end

      @kernel.exit(0)
    end

    def write_to(socket, &content)
      IO.select([], [socket])
      socket.write(content.call)
    end

    def read_from(socket, &handler)
      IO.select([socket])
      magic, type, args_length = socket.read(12).unpack('a4NN')

      if args_length > 0
        IO.select([socket])
        arguments = socket.read(args_length).split("\0")
      else
        arguments = []
      end

      packet = {
        magic: magic,
        type: type,
        arguments: arguments
      }

      handler.call(packet)
    end

  end
end
