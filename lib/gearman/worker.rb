require 'gearman/address/serializer'
require 'gearman/connection'
require 'gearman/packet'

module Gearman
  class Worker

    def initialize(address)
      @address = Address::Serializer.load(address)
      @connection_configuration = ->(address) { Connection.new(address) }
      build_connection
    end

    def can_do(ability)
      @connection.write(Packet::CAN_DO.new(function_name: ability))
    end

    def pre_sleep
      @connection.write(Packet::PRE_SLEEP.new)
      @connection.next(Packet::NOOP)
    end

    def grab_job
      @connection.write(Packet::GRAB_JOB.new)
      @connection.next(Packet::JOB_ASSIGN, Packet::NO_JOB)
    end

    def work_exception(handle, data)
      @connection.write(Packet::WORK_EXCEPTION.new(handle: handle, data: data))
    end

    def work_complete(handle, data)
      @connection.write(Packet::WORK_COMPLETE.new(handle: handle, data: data))
    end

    def disconnect
      @connection.disconnect if @connection.alive?
    end

    def with_connection
      yield @connection
    end

    def configure_connection(&configuration)
      @connection_configuration = configuration
      reconnect
    end

    def build_connection
      @connection = @connection_configuration.call(@address)
    end

    def reconnect
      if @connection.alive?
        @connection.terminate
      end

      build_connection
    end

  end
end
