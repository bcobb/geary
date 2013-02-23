require 'timeout'

module Geary
  class WorkerClient

    class PollTimeout < RuntimeError
    end

    attr_reader :packet_stream

    def initialize(options = {})
      @packet_stream = options.fetch(:packet_stream)
    end

    def can_do(function_name)
      packet_stream.write_request(:can_do, function_name)
    end

    def cant_do(function_name)
      packet_stream.write_request(:cant_do, function_name)
    end

    def reset_abilities
      packet_stream.write_request(:reset_abilities)
    end

    def grab_job
      packet_stream.request(:grab_job)
    end

    def grab_job_uniq
      packet_stream.request(:grab_job_uniq)
    end

    def pre_sleep
      packet_stream.write_request(:pre_sleep)
    end

    def has_jobs_waiting?
      begin
        Timeout.timeout(0.1, PollTimeout) do
          packet_stream.read
        end
      rescue PollTimeout
        false
      else
        true
      end
    end

  end
end
