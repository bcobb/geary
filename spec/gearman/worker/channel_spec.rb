require 'gearman_admin_client'
require 'gearmand_control'
require 'timeout'
require 'socket'
require 'thread'

module Gearman
  class Worker
    include Timeout

    NothingToRead = Class.new(RuntimeError)

    def initialize(socket)
      @socket = socket
      @socket_class = socket.class
    end

    def can_do(ability)
      body = [ability].join("\0")
      header = ["\0REQ", 1, body.size].pack('a4NN')
      packet = header + body

      @socket_class.select([], [@socket])
      @socket.write(packet)

      quickly do
        @socket_class.select([@socket])
        @socket.read
      end
    end

    def pre_sleep
      body = [].join("\0")
      header = ["\0REQ", 4, body.size].pack('a4NN')
      packet = header + body

      @socket_class.select([], [@socket])
      @socket.write(packet)

      quickly do
        @socket_class.select([@socket])
        @socket.read
      end
    end

    def listen
      slowly do
        @socket_class.select([@socket])
        unless @socket.eof?
          header = @socket.read(12).unpack('a4NN')
          magic, type, size = header

          if size > 0
            @socket_class.select([@socket])
            body = @socket.read(size)
          else
            body = nil
          end

          {
            magic: magic,
            type: type,
            size: size,
            body: body
          }
        end
      end
    end

    def quickly
      begin
        timeout(1e-6, NothingToRead) { yield }
      rescue NothingToRead 
      end
    end

    def slowly
      begin
        timeout(1, NothingToRead) { yield }
      rescue NothingToRead 
      end
    end

  end

  describe 'the channel' do

    def submit_job_bg(server_address, *function_names)
      host, port = server_address.split(':')
      socket = TCPSocket.new(host, port)

      function_names.each do |function_name|
        id = SecureRandom.hex
        request(socket, 18, [function_name, id, 'arg'])
      end
    end

    def request(socket, type, arguments)
      body = arguments.join("\0")
      header = ["\0REQ", type, body.size].pack('a4NN')

      socket.class.select([], [socket])
      socket.write(header + body)

      read_a_little_from(socket)
    end

    def read_a_little_from(socket)
      begin
        Timeout.timeout(1, RuntimeError) do
          socket.class.select([socket])
          header = socket.read(12).unpack('a4NN')
          if header.last > 0
            socket.class.select([socket])
            body = socket.read(header.last)
          end
        end
      rescue
      end
    end

    let!(:gearmand) { GearmandControl.new(4730) }
    let!(:admin) { GearmanAdminClient.new(gearmand.address) }

    before do
      gearmand.start
    end

    after do
      begin
        admin.shutdown
      rescue
        # don't care if we already shut it down
      end
    end

    it 'can do things' do
      admin.status.should be_empty

      socket = TCPSocket.new('localhost', 4730)
      worker = Worker.new(socket)
      worker.can_do 'something'

      admin.status.should_not be_empty
    end

    it 'is told to wake up after it tells the server it will sleep' do
      socket = TCPSocket.new('localhost', 4730)
      worker = Worker.new(socket)
      worker.can_do 'something'
      worker.pre_sleep

      listener = Thread.new { worker.listen }

      submit_job_bg(gearmand.address, 'something')

      worker_packet = listener.value

      expect(worker_packet[:type]).to eql(6)
    end

    example 'when it is listening and the server goes away' do
      socket = TCPSocket.new('localhost', 4730)
      worker = Worker.new(socket)
      worker.can_do 'something'
      worker.pre_sleep

      listener = Thread.new { worker.listen }

      admin.shutdown

      expect(listener.value).to be_nil
    end

  end

end
