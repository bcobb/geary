module Geary
  class TextStream

    attr_reader :connection

    def initialize(options = {})
      @connection = options.fetch(:connection)
    end

    def write(command)
      connection.on_writeable { |w| w.puts(command) }
    end

    def read
      connection.on_readable { |r| r.gets }
    end

    def drain
      output = ''

      while line = read
        break if line.chop == '.'
        output << line
      end

      output
    end

  end
end
