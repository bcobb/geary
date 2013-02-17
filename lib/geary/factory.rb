module Geary
  class Factory
    include Virtus::ValueObject

    attribute :host, String, :default => "localhost"
    attribute :port, Integer, :default => 4730

    def client
      socket = ::TCPSocket.new(host, port)
      translator = PacketTranslator.new
      reader = PacketReader.new(:source => socket, :translator => translator)

      Client.new(:packet_reader => reader)
    end

  end
end
