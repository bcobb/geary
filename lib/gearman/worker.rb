require 'celluloid'
require 'gearman/address/serializer'
require 'gearman/connection'
require 'gearman/packet'

module Gearman
  class Worker
    include Celluloid

    trap_exit :reconnect
    finalizer :disconnect

    def initialize(address)
      @address = Address::Serializer.load(address)
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
      if @connection
        @connection.terminate if @connection.alive?
      end
    end

    def build_connection
      @connection = Connection.new(@address)
      current_actor.link @connection
    end

    def reconnect(actor, reason)
      disconnect
      build_connection
    end

  end
end
