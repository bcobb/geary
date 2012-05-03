module Gearman

  module Request

    MAGIC = "\0REQ"

    class EchoReq

      def initialize(data)
        @request = Request.new(16, data)
      end

    end

    class SubmitJob

      def initialize(function_name, unique_id, data)
        @request = Request.new(7, function_name, unique_id, data)
      end

    end

    class SubmitJobHigh

      def initialize(function_name, unique_id, data)
        @request = Request.new(21, function_name, unique_id, data)
      end

    end

    class SubmitJobLow

      def initialize(function_name, unique_id, data)
        @request = Request.new(33, function_name, unique_id, data)
      end

    end

    class SubmitJobBg

      def initialize(function_name, unique_id, data)
        @request = Request.new(18, function_name, unique_id, data)
      end

    end

    class SubmitJobHighBg

      def initialize(function_name, unique_id, data)
        @request = Request.new(32, function_name, unique_id, data)
      end

    end

    class SubmitJobLowBg

      def initialize(function_name, unique_id, data)
        @request = Request.new(34, function_name, unique_id, data)
      end

    end

    class SubmitJobSched

      def initialize(function_name, unique_id, data)
        @request = Request.new(35, function_name, unique_id, minute, hour, mday,
                               month, wday, data)
      end

    end

    class SubmitJobEpoch

      def initialize(function_name, unique_id, epoch_time, data)
        @request = Request.new(36, function_name, unique_id, epoch_time, data)
      end

    end

    class GetStatus

      def initialize(job_handle)
        @request = Request.new(15, job_handle)
      end

    end

    class OptionReq

      def initialize(option_name)
        @request = Request.new(26, option_name)
      end

    end

    def initialize(type, *arguments)
      @packet = Packet.new MAGIC, type, arguments
    end

  end
end
