module Gearman

  class Request

    module Factory

      def type(number, name, *arguments)
        # XXX: raise ArgumentError if redefining a factory
        factory = %{
          def #{name}(#{arguments.join(", ")})
            new(#{number}, #{arguments.join(", ")})
          end
        }

        query = %{
          def #{name}?
            @packet.type.to_s == '#{number}' && @packet.magic == Request::MAGIC
          end
        }

        instance_eval factory
        class_eval query
      end

    end

    extend Factory

    MAGIC = "\0REQ"

    type 16, :echo_req, :data
    type 7, :submit_job, :function_name, :unique_id, :data
    type 21, :submit_job_high, :function_name, :unique_id, :data
    type 33, :submit_job_low, :function_name, :unique_id, :data
    type 18, :submit_job_bg, :function_name, :unique_id, :data
    type 32, :submit_job_high_bg, :function_name, :unique_id, :data
    type 34, :submit_job_low_bg, :function_name, :unique_id, :data
    type 35, :submit_job_sched, :function_name, :unique_id, :minute, :hour,
             :mday, :month, :wday, :data
    type 36, :submit_job_epoch, :function_name, :unique_id, :epoch_time, :data
    type 15, :get_status, :job_handle
    type 26, :option_req, :option_name

    def initialize(type, *arguments)
      @packet = Packet.new MAGIC, type, arguments
    end

    def to_s(serializer = Packet)
      serializer.dump(@packet)
    end

    def ==(request)
      request.to_s == to_s
    end

  end
end
