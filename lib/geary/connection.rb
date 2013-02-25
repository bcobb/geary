require 'forwardable'

module Geary
  class Connection
    extend Forwardable

    def_delegator :io, :close

    attr_reader :io

    def initialize(options = {})
      @io = options.fetch(:io)
    end

    def read(*args)
      on_readable { |r| r.read(*args) }
    end

    def write(*args)
      on_writeable { |w| w.write(*args) }
    end

    def on_readable
      readables, _ = IO::select([io])
      readable = readables.first

      yield readable
    end

    def on_writeable
      _, writeables = IO.select([], [io])
      writeable = writeables.first

      yield writeable
    end

  end
end
