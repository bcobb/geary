module Gearman

  class Stream

    def initialize(stream)
      @stream = stream
    end

    def write(data)
      on_writable { |stream| stream.write(data) }
    end

    def read(length)
      on_readable { |stream| stream.read(length) }
    end

    def close
      @stream.close
    end

    def closed?
      @stream.closed?
    end

    private

    def on_writable
      _, write_select = ::IO::select([], [@stream])

      yield write_select.first
    end

    def on_readable
      read_select, _ = ::IO::select([@stream])

      yield read_select.first
    end

  end

end

