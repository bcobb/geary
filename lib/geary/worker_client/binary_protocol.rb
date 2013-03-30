require 'forwardable'
require 'timeout'

module Geary
  module WorkerClient
    class BinaryProtocol
      extend Forwardable

      class PollTimeout < RuntimeError
      end

      def_delegator :connection, :close

      attr_reader :connection

      def initialize(options = {})
        @connection = options.fetch(:connection)
      end

      def can_do(function_name)
        connection.request(:can_do, function_name)
      end

      def can_do_timeout(function_name, timeout)
        connection.request(:can_do_timeout, function_name, timeout)
      end

      def cant_do(function_name)
        connection.request(:cant_do, function_name)
      end

      def reset_abilities
        connection.request(:reset_abilities)
      end

      def grab_job
        connection.request_with_response(:grab_job)
      end

      def grab_job_uniq
        connection.request_with_response(:grab_job_uniq)
      end

      def pre_sleep
        connection.request(:pre_sleep)
      end

      def send_work_status(job_handle, percent_complete)
        denominator = 100
        numerator = percent_complete * denominator

        arguments = [job_handle, numerator, denominator]

        connection.request(:work_status, *arguments)
      end

      def send_work_complete(job_handle, data)
        connection.request(:work_complete, job_handle, data)
      end

      def send_work_fail(job_handle)
        connection.request(:work_fail, job_handle)
      end

      def send_work_exception(job_handle, data)
        connection.request(:work_exception, job_handle, data)
      end

      def send_work_data(job_handle, data)
        connection.request(:work_data, job_handle, data)
      end

      def send_work_warning(job_handle, data)
        connection.request(:work_warning, job_handle, data)
      end

      def set_client_id(client_id)
        connection.request(:set_client_id, client_id)
      end

      def has_jobs_waiting?
        begin
          Timeout.timeout(1e-3, PollTimeout) do
            connection.read_response
          end
        rescue PollTimeout
          false
        else
          true
        end
      end

    end
  end
end
