require 'socket'

require 'gearman/packet'
require 'gearman/stream'
require 'gearman/server_connection'
require 'gearman/request'
require 'gearman/client'

module Gearman

  def self.connect(&block)
    begin
      socket = ::TCPSocket.new('localhost', '4730')
      server_connection = Gearman::ServerConnection.new(Stream.new(socket))
      block.call server_connection
    rescue => e
      puts 'Ack!'
    ensure
      server_connection.close_connection
    end

#    if connection_pool
#      connection_pool.with_connection do |server|
#        begin
#          block.call(server)
#        ensure
#          server.close_connection
#        end
#      end
#    end
  end

  def self.configuration
    @configuration ||= Gearman::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end

end
