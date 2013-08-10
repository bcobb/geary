require 'celluloid'
require 'logger'

class FakePerformer
  include Celluloid

  attr_reader :started, :server_address

  def initialize(server_address)
    @server_address = server_address
    @started = false
  end

  def start
    @started = true
  end

  def die
    without_logging { raise "I was told to die." }
  end

  def die_quietly
    without_logging { raise }
  end

  alias :started? :started

  private

  unless defined? QUIET_LOGGER
    QUIET_LOGGER = ::Logger.new(STDERR).tap { |l| l.level = ::Logger::FATAL }
  end

  def without_logging
    old_logger = Celluloid.logger

    begin
      Celluloid.logger = QUIET_LOGGER
      yield
    ensure
      Celluloid.logger old_logger
    end
  end

end
