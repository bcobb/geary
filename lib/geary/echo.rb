module Geary
  class Echo

    attr_reader :reader

    def initialize(reader)
      @reader = reader
    end

    def call(data)
      body = [data].join("\0")
      header = ["\0REQ", 16, body.size].pack('a4NN')

      _, writers = IO.select([], [reader.source])
      writers.first.write(header + body)

      reader.read
    end

  end
end
