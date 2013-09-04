require 'celluloid/io'

class FakeServer
  include Celluloid::IO

  finalizer :shutdown

  attr_reader :packets_read

  def initialize(address)
    @server = TCPServer.new(address.host, address.port)
    @packets_read = []
    @next_response = nil
    @repository = Gearman::Packet::Repository.new
  end

  def shutdown
    if @server
      @server.close unless @server.closed?
    end
  end

  def run
    loop do
      after(0) { signal :accept }
      async.handle_connection @server.accept
    end
  end

  def handle_connection(socket)
    header = socket.read(Gearman::Connection::HEADER_SIZE)
    magic, type, length = header.unpack(Gearman::Connection::HEADER_FORMAT)
    arguments = socket.read(length).split(Gearman::Connection::NULL_BYTE)

    packet = @repository.load(type).new(arguments)
    @packets_read.push(packet)

    signal :read_packet

    if @next_response
      body = @next_response.arguments.join(Gearman::Connection::NULL_BYTE)
      header = ["\0RES", @next_response.number, body.size].
        pack(Gearman::Connection::HEADER_FORMAT)

      socket.write(header + body)
      @next_response = nil
    end
  end

  def respond_with(packet)
    @next_response = packet
  end

end

