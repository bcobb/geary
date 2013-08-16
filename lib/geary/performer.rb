require 'celluloid/io'
require 'json'
require 'timeout'

module Geary

  unless defined? HEADER_FORMAT
    HEADER_FORMAT = 'a4NN'
    HEADER_SIZE = 12
    NULL_BYTE = "\0"
    REQ = [NULL_BYTE, "REQ"].join
  end

  class Performer
    include Celluloid::IO

    unless defined? Error
      Error = Class.new(RuntimeError)
      NoConnection = Class.new(Error)
      UnexpectedPacket = Class.new(Error)
      IncompleteWrite = Class.new(Error)
      IncompleteRead = Class.new(Error)
      Shutdown = Class.new(Error)
      TimeoutError = Class.new(Error)

      CAN_DO = 1
      PRE_SLEEP = 4
      NOOP = 6
      GRAB_JOB = 9
      NO_JOB = 10
      JOB_ASSIGN = 11
      WORK_COMPLETE = 13
      WORK_EXCEPTION = 25
    end

    attr_reader :address

    finalizer :disconnect

    def initialize(address)
      @address = address
    end

    def start
      connect
      announce_ability

      loop do
        _, type, arguments = grab_job

        if type == JOB_ASSIGN
          handle, _, data = arguments

          perform(handle, data)
        elsif type == NO_JOB
          pre_sleep

          _, type, _ = read_packet

          if type != NOOP
            unexpected! type, [NOOP]
          end
        else
          unexpected! type, [JOB_ASSIGN, NO_JOB]
        end
      end
    end

    def disconnect
      if @socket
        @socket.close unless @socket.closed?
      end
    end

    private

    def connect
      begin
        @socket = TCPSocket.new(address.host, address.port)
      rescue Errno::ECONNREFUSED
        raise NoConnection, "could not connect to #{address}"
      end
    end

    def announce_ability
      request(CAN_DO, ['Geary.default'])
    end

    def pre_sleep
      request(PRE_SLEEP)
    end

    def grab_job
      request(GRAB_JOB)

      read_packet
    end

    def perform(handle, data)
      job = JSON.parse(data)
      job_result = nil

      begin
        worker = ::Object.const_get(job['class']).new

        job_result = worker.perform(*job['args'])
      rescue => error
        request(WORK_EXCEPTION, [handle, error.message])
      else
        request(WORK_COMPLETE, [handle, String(job_result)])
      end
    end

    def request(type, arguments = [])
      body = arguments.join(NULL_BYTE)
      header = [REQ, type, body.size].pack(HEADER_FORMAT)
      packet = header + body

      length_written = @socket.write(packet)

      if length_written != packet.length
        lengths = [packet.length, lengths]
        message = "expected to write %d bytes, but only read %d" % lengths

        raise IncompleteWrite, message
      end
    end

    def unexpected!(type, expected)
      raise UnexpectedPacket, "expected #{expected.join(' or ')}, got #{type}"
    end

    def read_packet
      header = read(HEADER_SIZE)
      magic, type, length = header.unpack(HEADER_FORMAT)

      body = read(length)
      arguments = String(body).split(NULL_BYTE)

      [magic, type, arguments]
    end

    def read(length)
      return unless length > 0

      data = @socket.read(length)

      if data.length == length
        data
      else
        lengths = [length, data.length]
        message = "expected to read %d bytes, but only read %d" % lengths

        raise IncompleteRead, message
      end
    end

  end
end
