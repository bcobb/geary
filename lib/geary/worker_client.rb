require 'forwardable'
require 'timeout'

module Geary
  class WorkerClient
    extend Forwardable

    class PollTimeout < RuntimeError
    end

    def_delegator :packet_stream, :connection

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

    def send_work_status(job_handle, percent_complete)
      denominator = 100
      numerator = percent_complete * denominator

      arguments = [job_handle, numerator, denominator]

      packet_stream.write_request(:work_status, *arguments)
    end

    def send_work_complete(job_handle, data)
      packet_stream.write_request(:work_complete, job_handle, data)
    end

    def send_work_fail(job_handle)
      packet_stream.write_request(:work_fail, job_handle)
    end

    def send_work_exception(job_handle, data)
      packet_stream.write_request(:work_exception, job_handle, data)
    end

    def send_work_data(job_handle, data)
      packet_stream.write_request(:work_data, job_handle, data)
    end

    def send_work_warning(job_handle, data)
      packet_stream.write_request(:work_warning, job_handle, data)
    end

    def has_jobs_waiting?
      begin
        Timeout.timeout(1e-3, PollTimeout) do
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
