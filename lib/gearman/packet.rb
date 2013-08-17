require 'gearman/packet/repository'

module Gearman
  module Packet
    self.tap do
      Repository.new
    end
  end
end
