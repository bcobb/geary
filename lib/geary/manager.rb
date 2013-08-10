require 'celluloid'

module Geary
  class Manager
    include Celluloid

    attr_reader :configuration, :performers

    trap_exit :restart_performer

    def initialize(configuration: configuration, performer_type: Performer)
      @configuration = configuration
      @performers = []
      @server_addresses_by_performer = {}
      @performer_type = performer_type
    end

    def start
      configuration.server_addresses.each do |server_address|
        configuration.concurrency.times do
          start_performer(server_address)
        end
      end
    end

    def stop
      current_actor.links.each do |linked_performer|
        current_actor.unlink(linked_performer)
      end

      @performers.select!(&:alive?)
      @performers.each(&:terminate)

      signal(:stop)
    end

    private

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

      server_address = @server_addresses_by_performer.delete(_id)

      wants_server_address.call(server_address)
    end

    def start_performer(server_address)
      performer = @performer_type.new(server_address)

      @performers << performer
      @server_addresses_by_performer[performer.object_id] = server_address

      current_actor.link performer
      performer.async.start
    end

  end
end
