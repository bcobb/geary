require_relative 'factory'

module Geary
  class Worker < Module

    def initialize(options = {})
      @client = options.fetch(:client)
    end

    def included(class_)
      class_.extend(SubmitJobs)
      class_._gearman_client = @client
    end

    module SubmitJobs

      attr_accessor :_gearman_client

      def perform_async(*args)
        job_arguments = {
          :class => self.name,
          :args => args
        }
        _gearman_client.submit_job_bg(_function_name, job_arguments)
      end

      def perform_in(interval, *args)
        now = Time.now

        if interval.to_i <= now.to_i
          epoch = now + interval
        else
          epoch = Time.at(interval.to_i)
        end

        stamp = epoch.strftime("%-M %-H %-d %-m %w")
        date_args = stamp.split(' ').map(&:to_i)

        weekday = date_args.pop
        date_args.push(weekday - 1) # Gearman claims Monday = 0

        job_arguments = {
          :class => self.name,
          :args => args
        }
        arguments = date_args + [job_arguments]

        _gearman_client.submit_job_sched(_function_name, *arguments)
      end
      alias_method :perform_at, :perform_in

      private

      def _function_name
        'default'
      end

    end

  end
end
