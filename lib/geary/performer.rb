require 'celluloid'
require 'forwardable'
require 'gearman/worker'
require 'json'

module Geary

  class Performer
    include Celluloid
    extend Forwardable

    finalizer :disconnect
    trap_exit :reconnect

    def initialize(address)
      @address = address
      configure_connection Gearman::Worker.method(:new_link)
    end

    def start
      @gearman.can_do('Geary.default')

      loop do
        packet = @gearman.grab_job

        case packet
        when Gearman::Packet::JOB_ASSIGN
          perform(packet)
        when Gearman::Packet::NO_JOB
          idle
        else
          break
        end
      end
    end

    def idle
      @gearman.pre_sleep
    end

    def perform(packet)
      job = JSON.parse(packet.data)
      job_result = nil

      begin
        worker = ::Object.const_get(job['class']).new

        job_result = worker.perform(*job['args'])
      rescue => error
        @gearman.async.work_exception(packet.handle, error.message)
      else
        @gearman.async.work_complete(packet.handle, job_result)
      end
    end

    def disconnect
      if @gearman
        @gearman.terminate if @gearman.alive?
      end
    end

    def reconnect(actor, reason)
      disconnect
      build_connection
    end

    def build_connection
      @gearman = @connect.call(@address)
    end

    def configure_connection(connection_routine)
      @connect = connection_routine
      reconnect(current_actor, nil)
    end

  end
end
