require 'json'
require_relative '../gearman/client/channel'

module Geary
  module Worker

    def perform_async(*args)
      payload = { class: self, args: args }

      # TODO: configurable queue name and payload serialization
      begin
        gearman_channel.submit_job_bg('Geary.default', payload.to_json)
      rescue => e
        gearman_channel.reconnect

        retry
      end
    end

    protected

    def use_gearman_channel(channel)
      @gearman_channel = channel
    end

    def gearman_channel
      @gearman_channel || use_gearman_channel(
        Gearman::Client::Channel.new('localhost:4730')
      )
    end

  end
end
