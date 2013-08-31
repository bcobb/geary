require 'celluloid'
require 'geary/configuration'
require 'geary/performer'

module Geary
  class Manager
    include Celluloid

    JITTER = 0.01 unless defined? JITTER

    attr_reader :configuration, :performers

    trap_exit :performer_crashed

    def initialize(configuration: configuration, performer_type: Performer)
      @configuration = configuration
      @performers = []
      @crashes = []
      @server_addresses_by_performer = {}
      @performer_type = performer_type
    end

    def start
      async.monitor_crashes

      configuration.server_addresses.each do |server_address|
        configuration.concurrency.times do
          start_performer(server_address)
        end
      end
    end

    def stop
      @performers.select(&:alive?).each(&:terminate)

      after(0) { signal(:done) }
    end

    private

    def monitor_crashes
      every(configuration.failure_monitor_interval) do 
        @crashes.reject! do |server_address|
          momentarily { start_performer(server_address) }
        end
      end
    end

    def performer_crashed(performer, reason)
      if String(reason).size > 0
        forget_performer(performer) do |server_address|
          @crashes.unshift(server_address)
        end
      end
    end

    def forget_performer(performer, &wants_server_address)
      _id = performer.object_id

      @performers.delete(performer) do
        raise UnexpectedRestart, "we don't know about Performer #{_id}"
      end

      server_address = @server_addresses_by_performer.delete(_id)

      wants_server_address.call(server_address)
    end

    def start_performer(server_address)
      performer = @performer_type.new_link(server_address)

      @performers << performer
      @server_addresses_by_performer[performer.object_id] = server_address

      performer.async.start
    end

    def momentarily(&action)
      after(rand + JITTER, &action)
      true
    end

  end
end
