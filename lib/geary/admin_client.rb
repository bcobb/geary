require 'forwardable'

require_relative 'admin_client/worker'
require_relative 'admin_client/registered_function'

module Geary
  class AdminClient
    extend Forwardable

    def_delegator :packet_stream, :connection

    attr_reader :packet_stream

    def initialize(options = {})
      @packet_stream = options.fetch(:packet_stream)
    end

    def workers
      packet_stream.write('workers')
      output = packet_stream.drain.split("\n")

      output.map do |line|
        segments = line.split(':')

        function_names = segments.pop.strip.split(' ')

        remainder = segments.join(':')

        fd, ip_address, client_id = remainder.split(' ').map(&:strip)

        Worker.new(
          :file_descriptor => fd,
          :ip_address => ip_address,
          :client_id => client_id,
          :function_names => function_names
        )
      end
    end

    def status
      packet_stream.write('status')
      output = packet_stream.drain.split("\n")

      output.map do |line|
        function_name, total, running, workers = line.split("\t")

        RegisteredFunction.new(
          :name => function_name,
          :jobs_in_queue => total,
          :running_jobs => running,
          :available_workers => workers
        )
      end
    end

    def server_version
      packet_stream.write('version')
      packet_stream.read.strip
    end

    def shutdown(graceful = false)
      command = 'shutdown'

      if graceful
        command << 'graceful'
      end

      packet_stream.write(command.join(' '))
    end

  end
end
