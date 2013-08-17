require 'celluloid'

module Geary
  class PacketTrail
    include Celluloid

    def initialize
      @file = File.new('tmp/trail', 'a')
    end

    def push(time, packet)
      _, type, _ = packet

      @file.puts([time, type, '='].join(' '))
    end

    def stop
      @file.close
    end

  end
end
