require 'timeout'
require 'socket'

class GearmanServerProcess

  def self.start(command = "gearmand")
    new(command).tap(&:start)
  end

  def initialize(command = "gearmand")
    @command = command
    @io = nil
  end

  def start
    @io = IO.popen(@command)
  end

  def stop(signal = :TERM)
    if @io
      Process.kill(signal, @io.pid)
      @io.close
    end
  end

  def test!
    socket = nil
    begin
      socket = TCPSocket.new('localhost', 4730)
    rescue Errno::ECONNREFUSED
      retry
    ensure
      socket && socket.close
    end
  end

end

AfterConfiguration do
  Timeout.timeout(1) do
    gearmand = GearmanServerProcess.start

    at_exit { gearmand.stop }

    gearmand.test!
  end
end
