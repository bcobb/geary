require 'timeout'
require 'gearman/client/channel'

module Gearman
  module Client

    describe Channel do

      it 'submits background jobs' do
        server = Thread.new { `gearmand` }

        channel = Channel.new('localhost:4730')
        job_created = channel.submit_job_bg('gearman.channel.test')

        status = []

        socket = nil

        Timeout.timeout(1) do
          begin
            socket = TCPSocket.new('localhost', 4730)
          rescue Errno::ECONNREFUSED
            retry
          end
        end

        IO::select([], [socket])

        socket.puts("status")
        IO::select([socket])

        while line = socket.gets
          break if line.chop == '.'
          status << line
        end

        expect(status.join("\n")).to include('gearman.channel.test')
      end

    end

  end
end
