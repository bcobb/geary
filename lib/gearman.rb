require 'socket'

require 'gearman/packet'
require 'gearman/stream'
require 'gearman/server_connection'
require 'gearman/request'
require 'gearman/response'
require 'gearman/client'

module Gearman

  class ConnectionError < StandardError ; end

  def self.connect(&block)
    begin
      socket = ::TCPSocket.new('localhost', '4730')
      server_connection = Gearman::ServerConnection.new(Stream.new(socket))

      if defined? IRB
        puts "continue?"
        gets
      end

      block.call server_connection
    rescue Errno::ECONNREFUSED => e
      raise ConnectionError, "Could not connect to Gearman"
    rescue => e
      puts e.inspect
      puts "  #{e.backtrace.join("\n  ")}"
    ensure
      server_connection.close_connection if server_connection
    end
  end

  def self.configuration
    @configuration ||= Gearman::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end

end
