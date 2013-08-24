require 'celluloid'
require 'gearman/address/serializer'
require 'gearman/connection'
require 'gearman/packet'
require 'securerandom'

module Gearman
  class Client

    def initialize(address)
      @address = Address::Serializer.load(address)
      @generate_unique_id = SecureRandom.method(:uuid)
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

    def generate_unique_id_with(methodology)
      @generate_unique_id = methodology
    end

    def disconnect
      if @connection
        @connection.terminate if @connection.alive?
      end
    end

    def build_connection
      @connection = Connection.new(@address)
    end

    def reconnect
      disconnect
      build_connection
    end

  end
end
