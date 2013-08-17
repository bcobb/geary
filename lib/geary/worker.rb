require 'json'
require 'gearman/client'

module Geary
  module Worker

    def perform_async(*args)
      payload = { class: self, args: args }

      # TODO: configurable queue name and payload serialization
      begin
        gearman_client.submit_job_bg('Geary.default', payload.to_json)
      rescue => e
        gearman_client.reconnect

        retry
      end
    end

    protected

    def use_gearman_client(*args)
      @gearman_client = Gearman::Client.new(*args)
    end

    def gearman_client
      @gearman_client || use_gearman_client('localhost:4730')
    end

  end
end
