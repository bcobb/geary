require 'json'
require 'gearman/client'

module Geary
  module Worker

    def perform_async(*args)
      payload = { class: self, args: args }

      attempts = 0
      failure_threshold = 1

      # TODO: configurable queue name and payload serialization
      begin
        gearman_client.submit_job_bg('Geary.default', payload.to_json)
      rescue => e
        attempts += 1

        if attempts > failure_threshold
          raise
        else
          gearman_client.reconnect
          retry
        end
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
