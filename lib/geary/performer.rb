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

    def_delegator :@gearman, :disconnect

    def initialize(address)
      @gearman = Gearman::Worker.new(address)
    end

    def start
      @gearman.with_connection do |connection|
        current_actor.link connection
      end

      @gearman.can_do('Geary.default')

      loop do
        packet = @gearman.grab_job

        case packet
        when Gearman::Packet::JOB_ASSIGN
          perform(packet)
        when Gearman::Packet::NO_JOB
          idle
        end
      end
    end

    def disconnect
      @gearman.disconnect
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
        @gearman.work_exception(packet.handle, error.message)
      else
        @gearman.work_complete(packet.handle, job_result)
      end
    end

    def reconnect(actor, reason)
      @gearman.reconnect
    end

  end
end
