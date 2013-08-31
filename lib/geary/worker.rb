require 'json'
require 'gearman/client'
require 'geary/error'

module Geary
  module Worker

    def perform_async(*args)
      payload = payload_for(args)

      operation do |gearman|
        gearman.submit_job_bg('Geary.default', payload.to_json)
      end
    end

    protected

    def use_gearman_client(*args)
      @gearman_client = Gearman::Client.new(*args)
    end

    def gearman_client
      @gearman_client || use_gearman_client('localhost:4730')
    end

    def payload_for(args)
      payload = { class: self, args: args }
    end

    def operation(&block)
      attempts = 0
      failure_threshold = 1

      begin
        block.call(gearman_client)
      rescue
        attempts += 1

        if attempts > failure_threshold
          raise Error
        else
          gearman_client.reconnect
          retry
        end
      end
    end

  end
end
