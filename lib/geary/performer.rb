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
      begin
        @socket = TCPSocket.new(address.host, address.port)
      rescue Errno::ECONNREFUSED
        raise NoConnection, "could not connect to #{address}"
      end

      request(CAN_DO, ['Geary.default'])
      offer_to_work

      loop do
        _, type, _ = read_packet

        if type == NOOP
          offer_to_work
        else
          unexpected! type, [NOOP]
        end
      end
    end

    def offer_to_work
      _, type, arguments = grab_job

      handle_work_offer(type, arguments)
    end

    def handle_work_offer(type, arguments)
      if type == JOB_ASSIGN
        handle, _, data = arguments

        perform(handle, data)

        offer_to_work
      elsif type == NO_JOB
        request(PRE_SLEEP)
      else
        unexpected! type, [JOB_ASSIGN, NO_JOB]
      end
    end

    def grab_job
      request(GRAB_JOB)

      read_packet
    end

    def perform(handle, data)
      job = JSON.parse(data)
      job_result = nil

      ::Object.const_get(job['class']).new

      begin
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

      @socket.wait_writable
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
      read(HEADER_SIZE) do |header|
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

      @socket.wait_readable
      data = @socket.read(length)

      if @socket.eof?
        raise NoConnection, "lost connection to #{@address}"
      else
        if data.length == length
          handler.call(data)
        else
          lengths = [length, data.length]
          message = "expected to read %d bytes, but only read %d" % lengths

          raise IncompleteRead, message
        end
      end
    end

    def disconnect
      if @socket
        @socket.close unless @socket.closed?
      end
    end

  end
end
