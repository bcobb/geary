require 'forwardable'

module Geary
  module Client
    class BinaryProtocol
      extend Forwardable

      def_delegator :connection, :close

      attr_reader :connection, :unique_id_generator

      def initialize(options = {})
        @connection = options.fetch(:connection)
        @unique_id_generator = options.fetch(:unique_id_generator)
      end

      def echo(data)
        connection.request_with_response(:echo_req, data)
      end

      def submit_job(function_name, data)
        submit_job_as(:submit_job, function_name, data)
      end

      def submit_job_high(function_name, data)
        submit_job_as(:submit_job_high, function_name, data)
      end

      def submit_job_low(function_name, data)
        submit_job_as(:submit_job_low, function_name, data)
      end

      def submit_job_bg(function_name, data)
        submit_job_as(:submit_job_bg, function_name, data)
      end

      def submit_job_high_bg(function_name, data)
        submit_job_as(:submit_job_high_bg, function_name, data)
      end

      def submit_job_low_bg(function_name, data)
        submit_job_as(:submit_job_low_bg, function_name, data)
      end

      def submit_job_sched(function_name, minute, hour, day, month, wday, data)
        submit_job_as(:submit_job_sched, function_name, minute, hour, day, month,
                      wday, data)
      end

      def submit_job_epoch(function_name, epoch_time, data)
        submit_job_as(:submit_job_epoch, function_name, epoch_time, data)
      end

      def submit_job_as(job_type, function_name, *args)
        unique_id = unique_id_generator.generate(function_name, args)

        connection.request_with_response(job_type, function_name, unique_id, *args)
      end

      def get_status(job_handle)
        connection.request_with_response(:get_status, job_handle)
      end

      def set_server_option(option_name)
        connection.request_with_response(:option_req, option_name)
      end

    end
  end
end
