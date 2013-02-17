module Geary
  class PacketReader

    attr_reader :source, :translator

    def initialize(options = {})
      @source = options.fetch(:source)
      @translator = options.fetch(:translator)
    end

    def read
      magic, type, arguments_length = read_packet_header
      arguments = read_packet_arguments(arguments_length)

      translator.translate(magic, type, arguments)
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
      readables, _ = IO::select([source])
      readable = readables.first

      yield readable
    end

  end
end
