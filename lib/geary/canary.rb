require 'celluloid'
require 'socket'
require 'timeout'

require 'geary/error'

module Geary
  class Canary
    include Celluloid

    TimedOut = Class.new(::Geary::Error)

    def initialize(address, timeout: 5)
      @address = address
      @timeout = timeout
    end

    def alive?
      socket = nil

      begin
        Timeout.timeout(@timeout, TimedOut) do
          socket = TCPSocket.new(@address.host, @address.port)
        end
      rescue Errno::ECONNREFUSED, TimedOut
        false
      else
        true
      ensure
        if socket
          socket.close unless socket.closed?
        end
      end
    end

  end
end
