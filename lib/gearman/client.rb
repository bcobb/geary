require 'forwardable'
require 'gearman/address/serializer'
require 'gearman/connection'
require 'gearman/packet'
require 'securerandom'

module Gearman
  class Client
    extend Forwardable

    def_delegator :@connection, :disconnect

    def initialize(address)
      @address = Address::Serializer.load(address)
      @generate_unique_id = SecureRandom.method(:uuid)
      @connection_configuration = ->(address) { Connection.new(address) }
      build_connection
    end

    def submit_job_bg(function_name, data)
      packet = Packet::SUBMIT_JOB_BG.new(
        function_name: function_name,
        unique_id: @generate_unique_id.(),
        data: data
      )

      @connection.write(packet)
      @connection.async.next
    end

    def build_connection
      @connection = @connection_configuration.call(@address)
    end

    def configure_connection(&configuration)
      @connection_configuration = configuration
      reconnect
    end

    def generate_unique_id_with(&methodology)
      @generate_unique_id = methodology
    end

    def reconnect
      if @connection.alive?
        @connection.terminate
      end

      build_connection
    end

  end
end
