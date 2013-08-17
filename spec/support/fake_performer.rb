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
    raise "I was told to die."
  end

  def die_quietly
    raise
  end

  alias :started? :started

end
