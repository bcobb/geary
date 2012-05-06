module Gearman

  class Response

    MAGIC = "\0RES"

    class EchoRes

      attr_reader :data

      def initialize(data)
        @data = data
      end

    end

    class JobCreated

      attr_reader :job_handle

      def initialize(job_handle)
        @job_handle = job_handle
      end

    end

    class StatusRes

      attr_reader :job_handle, :known, :running, :numerator, :denominator

      def initialize(job_handle, known, running, numerator, denominator)
        @job_handle = job_handle
        @known = known.to_i == 1
        @running = running.to_i == 1
        @numerator = numerator.to_f
        @denominator = denominator.to_f
      end

      alias :known? :known
      alias :running? :running

      def percent_complete
        return 0.0 if [numerator, denominator].any?(&:zero?)

        (numerator / denominator) * 100.0
      end

    end

    def self.echo_res(packet)
      data, _ = packet.arguments
      EchoRes.new(data)
    end

    def self.job_created(packet)
      job_handle, _ = packet.arguments
      JobCreated.new(job_handle)
    end

    def self.get_status(packet)
      job_handle, known, running, numerator, denominator = packet.arguments
      StatusRes.new(job_handle, known, running, numerator, denominator)
    end

  end

end
