module Geary
  class Client

    attr_reader :packet_reader

    def initialize(options = {})
      @packet_reader = options.fetch(:packet_reader)
    end

    def echo(data)
      body = [data].join("\0")
      header = ["\0REQ", 16, body.size].pack('a4NN')

      _, writers = IO.select([], [packet_reader.source])
      writers.first.write(header + body)

      packet_reader.read
    end

  end
end
