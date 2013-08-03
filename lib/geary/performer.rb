require 'socket'
require 'celluloid'

module Geary

  HEADER_FORMAT = 'a4NN'
  NULL_BYTE = "\0"
  REQ = [NULL_BYTE, "REQ"].join

  class Performer
    include Celluloid

    Error = Class.new(RuntimeError)
    ClosedConnection = Class.new(Error)
    UnexpectedPacket = Class.new(Error)
    IncompleteWrite = Class.new(Error)
    IncompleteRead = Class.new(Error)
    Shutdown = Class.new(Error)

    CAN_DO = 1
    PRE_SLEEP = 4
    NOOP = 6
    GRAB_JOB = 9
    JOB_ASSIGN = 11
    WORK_COMPLETE = 13

    attr_reader :address

    def initialize(address, manager_signals)
      @address = address
      @manager_signals = manager_signals
    end

    def start
      @socket = TCPSocket.new(address.host, address.port)

      request(CAN_DO, ['Geary.default'])
      request(PRE_SLEEP)

      loop do
        _, type, _ = read_packet

        if type == NOOP
          _, type, arguments = grab_job

          if type == JOB_ASSIGN
            handle, _, data = arguments

            perform(handle, data)
          elsif type == NO_JOB
            next
          else
            unexpected! type, [JOB_ASSIGN, NO_JOB]
          end
        else
          unexpected! type, [NOOP]
        end
      end
    end

    def grab_job
      request(GRAB_JOB)

      read_packet
    end

    def perform(handle, data)
      json = JSON.parse(data)

      worker_class_name = json['class']
      worker_class = ::Object.const_get(worker_class_name)
      worker = worker_class.new
      begin
        worker.perform(*json['args'])
      rescue Exception => exception
        $stdout.puts exception
        $stdout.puts exception.message
        $stdout.puts exception.backtrace.join("\n")
      end

      request(WORK_COMPLETE, [handle, ''])
    end

    def request(type, arguments = [])
      body = arguments.join(NULL_BYTE)
      header = [REQ, type, body.size].pack(HEADER_FORMAT)

      write_packet(header + body)
    end

    def unexpected!(type, expected)
      raise UnexpectedPacket, "expected #{expected.join(' or ')}, got #{type}"
    end

    def read_packet
      read(12) do |header|
        magic, type, length = header.unpack(HEADER_FORMAT)
        arguments = []

        read(length) do |body|
          arguments = body.split(NULL_BYTE)
        end

        [magic, type, arguments]
      end
    end

    def read(length, &handler)
      return unless length > 0

      ready, _ = @socket.class.select([@socket, @manager_signals])

      if ready.include?(@manager_signals)
        signal = @manager_signals.gets.strip

        @socket.close

        raise Shutdown, "shutting down"
      end

      if @socket.eof?
        @socket.close

        raise ClosedConnection, "lost connection to #{@address}"
      else
        data = @socket.read(length)

        if data.length == length
          handler.call(data)
        else
          lengths = [length, data.length]
          message = "expected to read %d bytes, but only read %d" % lengths

          raise IncompleteRead, message
        end
      end
    end

    def stop
      begin
        @socket.close
      rescue ClosedConnection
      end
    end

    def write_packet(packet)
      @socket.class.select([], [@socket])
      length_written = @socket.write(packet)

      if length_written != packet.length
        lengths = [packet.length, lengths]
        message = "expected to write %d bytes, but only read %d" % lengths

        raise IncompleteWrite, message
      end
    end

  end
end
