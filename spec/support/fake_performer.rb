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
    after(0) { raise "I was told to die." }
  end

  def die_quietly
    after(0) { raise }
  end

  alias :started? :started

end
