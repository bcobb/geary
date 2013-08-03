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

    def grab_job
      body = [].join("\0")
      header = ["\0REQ", 9, body.size].pack('a4NN')
      packet = header + body

      @socket_class.select([], [@socket])
      @socket.write(packet)

      @socket_class.select([@socket])
      magic, type, size = @socket.read(12).unpack('a4NN')

      if size > 0
        @socket_class.select([@socket])
        arguments = @socket.read(size).split("\0")
      else
        arguments = []
      end

      if Integer(type) == 10
        # NO_JOB
      elsif Integer(type) == 11
        if @current_job.nil?
          @current_job = arguments
        else
          raise "Already working on one thing"
        end
      else
        raise "Got unexpected type #{type}"
      end
    end

    def work_complete
      if @current_job
        body = [@current_job.first, @current_job.last].join("\0")
        header = ["\0REQ", 13, body.size].pack('a4NN')
        packet = header + body

        @socket_class.select([], [@socket])
        @socket.write(packet)

        @current_job = nil

        quickly do
          @socket_class.select([@socket])
          @socket.read
        end
      end
    end

    def listen
      slowly do
        @socket_class.select([@socket])
        if @socket.eof?
          @socket.close
        else
          header = @socket.read(12).unpack('a4NN')
          magic, type, size = header

          if size > 0
            @socket_class.select([@socket])
            body = @socket.read(size)
          else
            body = nil
          end

          if Integer(type) != 6
            raise "Did not expect to be woken up by a #{type}"
          end

          Integer(type)
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
    include Timeout

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

      expect(worker_packet).to eql(6)
    end

    example 'when it is listening and the server goes away' do
      socket = TCPSocket.new('localhost', 4730)
      worker = Worker.new(socket)
      worker.can_do 'something'
      worker.pre_sleep

      listener = Thread.new { worker.listen }

      admin.shutdown

      expect(listener.value).to be_nil
      expect(socket).to be_closed
    end

    example 'when it connects and there are jobs waiting, and it tries to sleep' do
      submit_job_bg(gearmand.address, 'something')

      socket = TCPSocket.new('localhost', 4730)
      worker = Worker.new(socket)

      worker.can_do 'something'
      worker.pre_sleep

      listener = Thread.new { worker.listen }

      expect(listener.value).to eql(6)
    end

    example 'when it is in the middle of working and another job is submitted' do
      submit_job_bg(gearmand.address, 'something')

      socket = TCPSocket.new('localhost', 4730)
      worker = Worker.new(socket)

      worker.can_do 'something'
      worker.grab_job

      submit_job_bg(gearmand.address, 'something')

      expect(worker.work_complete).to be_nil

      worker.pre_sleep

      expect(worker.listen).to_not be_nil
      expect(worker.grab_job).to_not be_nil
    end

    example 'when attempting to do two things at once' do
      submit_job_bg(gearmand.address, 'something')

      socket = TCPSocket.new('localhost', 4730)
      worker = Worker.new(socket)

      worker.can_do 'something'
      worker.grab_job

      submit_job_bg(gearmand.address, 'something')

      expect do
        worker.grab_job
      end.to_not raise_error
    end

    example 'when a worker socket closes prematurely' do
      submit_job_bg(gearmand.address, 'something')

      socket = TCPSocket.new('localhost', 4730)
      worker = Worker.new(socket)

      worker.can_do 'something'
      worker.grab_job
      
      expect(admin.status.map(&:running_jobs)).to eql([1])

      socket.close

      expect(admin.status.map(&:running_jobs)).to eql([0])
    end

    example 'when a worker socket closes prematurely and there is a backup worker' do
      submit_job_bg(gearmand.address, 'something')

      flaky_socket = TCPSocket.new('localhost', 4730)
      flaky_worker = Worker.new(flaky_socket)

      backup_socket = TCPSocket.new('localhost', 4730)
      backup_worker = Worker.new(backup_socket)

      flaky_worker.can_do 'something'
      flaky_worker.grab_job

      backup_worker.can_do 'something'
      
      expect(admin.status.map(&:running_jobs)).to eql([1])

      flaky_socket.close

      sleep 1

      expect(admin.status.map(&:running_jobs)).to eql([0])

      backup_worker.grab_job

      expect(admin.status.map(&:running_jobs)).to eql([1])
    end

  end

end
