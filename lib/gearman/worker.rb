require 'celluloid'
require 'gearman/connection'
require 'gearman/packet'
require 'uri'

module Gearman
  class Worker
    include Celluloid

    trap_exit :reconnect
    finalizer :disconnect

    def initialize(address)
      @address = URI(address)
      configure_connection Connection.method(:new_link)
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
      if @connection
        @connection.terminate if @connection.alive?
      end
    end

    def build_connection
      @connection = @connect.call(@address)
    end

    def reconnect(*_)
      disconnect
      build_connection
    end

    def configure_connection(connection_routine)
      @connect = connection_routine
      reconnect
    end

  end
end
