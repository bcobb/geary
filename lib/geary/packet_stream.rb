require_relative 'magic'

module Geary
  class PacketStream

    FORMAT = 'a4NN' unless defined? FORMAT

    attr_reader :connection, :packet_type_repository

    def initialize(options = {})
      @connection = options.fetch(:connection)
      @packet_type_repository = options.fetch(:packet_type_repository)
      @packet_queue = []
    end

    def request(type, *arguments)
      write_request(type, *arguments)

      read
    end

    def write_request(type, *arguments)
      write(Magic::REQUEST, type, *arguments)
    end

    def read
      magic, type, arguments_length = read_packet_header

      if arguments_length > 0
        arguments = read_packet_arguments(arguments_length)
      else
        arguments = []
      end

      new_packet(magic, type, :arguments => arguments)
    end

    def write(magic, type, *arguments)
      packet = new_packet(magic, type, :arguments => arguments)

      body = packet.arguments.join("\0")
      header = [packet.magic, packet.protocol_number, body.size].pack(FORMAT)

      on_writeable do |writeable|
        writeable.write(header + body)
      end
    end

    def read_packet_arguments(length)
      on_readable do |readable|
        readable.read(length).split("\0")
      end
    end

    def read_packet_header
      on_readable do |readable|
        readable.read(12).unpack(FORMAT)
      end
    end

    def on_readable
      readables, _ = IO::select([connection])
      readable = readables.first

      yield readable
    end

    def on_writeable
      _, writeables = IO.select([], [connection])
      writeable = writeables.first

      yield writeable
    end

    def new_packet(magic, type, *args)
      packet_type_repository.find(magic, type).new(*args)
    end

  end
end
