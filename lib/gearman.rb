require 'gearman/packet'
require 'gearman/stream'
require 'gearman/request'
require 'gearman/client'

module Gearman

  def self.connect(&block)
    if connection_pool
      connection_pool.with_connection do |server|
        begin
          block.call(server)
        ensure
          server.close_connection
        end
      end
    end
  end

  def self.configuration
    @configuration ||= Gearman::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end

end
