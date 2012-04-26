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

    private

    def on_writable(&block)
      _, write_select = ::IO::select([], [@stream])
      if write_stream = write_select[0]
        yield write_stream
      end
    end

    def on_readable(&block)
      read_select, _ = ::IO::select([@stream])
      if read_stream = read_select[0]
        yield read_stream
      end
    end

  end

end

