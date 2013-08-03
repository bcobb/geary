require 'celluloid'

module Geary
  class Manager
    include Celluloid

    trap_exit :restart_performer

    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
      @performers = []
      @server_addresses_by_performer = {}
      @queues_by_performer = {}
      @shutting_down = false
    end

    def start_managing
      configuration.server_addresses.each do |server_address|
        configuration.concurrency.times do
          start_performer(server_address)
        end
      end
    end

    def stop_managing
      @performers.each { |performer| current_actor.unlink(performer) }

      shutting_down!

      @queues_by_performer.each do |performer, queue|
        queue.puts('INT')
      end

      living_performers = @performers.select(&:alive?)
      living_performers.each(&:terminate)

      signal(:shutdown)
    end

    def restart_performer(performer, reason)
      if String(reason).empty?
      else
        forget_performer(performer) do |server_address|
          start_performer(server_address)
        end
      end
    end

    def forget_performer(performer, &wants_server_address)
      _id = performer.object_id

      @performers.delete(performer) do
        raise UnexpectedRestart, "we don't know about Performer #{_id}"
      end

      @queues_by_performer.delete(_id)
      server_address = @server_addresses_by_performer.delete(_id)

      wants_server_address.call(server_address)
    end
    private :forget_performer

    def start_performer(server_address)
      performer_reads_from, manager_writes_to = IO.pipe
      performer = Performer.new(server_address, performer_reads_from)

      @performers << performer
      @server_addresses_by_performer[performer.object_id] = server_address
      @queues_by_performer[performer.object_id] = manager_writes_to

      current_actor.link performer
      performer.async.start
    end

    def shutting_down?
      @shutting_down
    end

    def shutting_down!
      @shutting_down = true
    end

  end
end
