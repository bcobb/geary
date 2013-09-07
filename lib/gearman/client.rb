require 'celluloid'
require 'gearman/connection'
require 'gearman/packet'
require 'securerandom'
require 'uri'

module Gearman
  class Client
    include Celluloid

    trap_exit :reconnect
    finalizer :disconnect

    def initialize(*addresses)
      @addresses = addresses.map(&Kernel.method(:URI))
      @generate_unique_id = SecureRandom.method(:uuid)
      @addresses_by_connection_id = {}
      @connections = []
      build_connections
    end

    def submit_job_bg(function_name, data)
      packet = Packet::SUBMIT_JOB_BG.new(
        function_name: function_name,
        unique_id: @generate_unique_id.(),
        data: data
      )

      with_connection do |connection|
        connection.write(packet)
        connection.async.next
      end
    end

    def generate_unique_id_with(methodology)
      @generate_unique_id = methodology
    end

    def disconnect
      @connections.select(&:alive?).each(&:terminate)
    end

    def build_connections
      @addresses.each do |address|
        build_connection(address)
      end
    end

    def build_connection(address)
      connection = Connection.new_link(address)
      @addresses_by_connection_id[connection.object_id] = address
      @connections << connection
    end

    def reconnect(connection = nil, _ = nil)
      connection ||= current_connection
      connection.terminate if connection.alive?

      forget_connection(connection) do |address|
        build_connection(address)
      end
    end

    def with_connection(&action)
      action.call(current_connection).tap do
        @connections.rotate!
      end
    end

    def current_connection
      @connections.first
    end

    def forget_connection(connection)
      @connections.delete(connection)
      yield @addresses_by_connection_id[connection.object_id]
    end

  end
end
