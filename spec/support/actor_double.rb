require 'celluloid'

module ActorDouble

  class Actor
    include Celluloid
  end

  def actor_double
    Actor.new
  end

end
