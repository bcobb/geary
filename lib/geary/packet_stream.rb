module Geary
  class PacketStream

    attr_reader :connection, :packet_type_repository

    def initialize(options = {})
      @connection = options.fetch(:connection)
      @packet_type_repository = options.fetch(:packet_type_repository)
    end

    def read
      magic, type, arguments_length = read_packet_header
      arguments = read_packet_arguments(arguments_length)

      packet_type_repository.packet(type, :arguments => arguments)
    end

    def write(type, *arguments)
      packet = packet_type_repository.packet(type, :arguments => arguments)

      body = packet.arguments.join("\0")
      header = [packet.magic, packet.type, body.size].pack('a4NN')

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
        readable.read(12).unpack('a4NN')
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

  end
end
