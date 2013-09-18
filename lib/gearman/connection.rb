require 'celluloid/io'
require 'gearman/packet'
require 'gearman/error'

module Gearman
  class Connection
    include Celluloid::IO

    finalizer :disconnect

    unless defined? IncompleteReadError
      IncompleteReadError = Class.new(Gearman::Error)
      IncompleteWriteError = Class.new(Gearman::Error)
      NoConnectionError = Class.new(Gearman::Error)
      UnexpectedPacketError = Class.new(Gearman::Error)
      ServerError = Class.new(Gearman::Error)

      NULL_BYTE = "\0"
      REQ = [NULL_BYTE, "REQ"].join
      HEADER_FORMAT = "a4NN"
      HEADER_SIZE = 12
    end

    def initialize(address)
      @address = address
      @repository = Packet::Repository.new
      @socket = nil
    end

    def write(packet)
      connect if disconnected?

      body = packet.arguments.join(NULL_BYTE)
      header = [REQ, packet.number, body.size].pack(HEADER_FORMAT)

      serialized_packet = header + body

      length_written = @socket.write(serialized_packet)

      debug "Wrote #{packet.inspect}"

      if length_written != serialized_packet.length
        lengths = [serialized_packet.length, lengths]
        message = "expected to write %d bytes, but only read %d" % lengths

        raise IncompleteWriteError, message
      end
    end

    def next(*expected_packet_types)
      connect if disconnected?

      header = read(HEADER_SIZE)
      magic, type, length = header.unpack(HEADER_FORMAT)

      body = read(length)
      arguments = String(body).split(NULL_BYTE)

      @repository.load(type).new(arguments).tap do |packet|
        debug "Read #{packet.inspect}"

        if packet.is_a?(Packet::ERROR)
          message = "server sent error #{packet.error_code}: #{packet.text}"

          raise ServerError, message
        end

        verify packet, expected_packet_types
      end
    end

    def disconnect
      if @socket
        @socket.close unless @socket.closed?
        @socket = nil
      end
    end

    private

    def read(length)
      return unless length > 0

      data = @socket.read(length)

      if data.nil?
        raise NoConnectionError, "lost connection to #{@address}"
      elsif data.length != length
        lengths = [length, data.length]
        message = "expected to read %d bytes, but only read %d" % lengths

        raise IncompleteReadError, message
      else
        data
      end
    end

    def connect
      begin
        @socket = TCPSocket.new(@address.host, @address.port)

        info "Connected"
      rescue => error
        raise NoConnectionError.new("could not connect to #{@address}", error)
      end
    end

    def disconnected?
      @socket.nil?
    end

    def verify(packet, valid_packet_types)
      return if valid_packet_types.empty?

      unless valid_packet_types.include?(packet.class)
        valid_type = valid_packet_types.join(' or ')
        message = "expected #{packet} to be a #{valid_type}"

        raise UnexpectedPacketError, message
      end
    end

    def debug(note)
      Celluloid.logger.debug "#{@address}: #{note}"
    end

    def info(note)
      Celluloid.logger.info "#{@address}: #{note}"
    end

  end
end
