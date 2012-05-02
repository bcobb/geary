module Gearman

  class Request

    module Factory

      def type(mapping, *arguments)
        factories = mapping.map do |type, method|
          %{
            def #{method}(#{arguments.join(", ")})
              new(#{type}, #{arguments.join(", ")})
            end
          }
        end

        instance_eval factories.join
      end

    end

    extend Factory

    MAGIC = "\0REQ"

    type 16 => :echo, :data
    type 7 => :submit_job, :function_name, :unique_id, :data
    type 21 => :submit_job_high, :function_name, :unique_id, :data
    type 33 => :submit_job_low, :function_name, :unique_id, :data
    type 18 => :submit_job_bg, :function_name, :unique_id, :data
    type 32 => :submit_job_high_bg, :function_name, :unique_id, :data
    type 34 => :submit_job_low_bg, :function_name, :unique_id, :data
    type 36 => :submit_job_epoch, :function_name, :unique_id, :data
    type 36 => :get_status, :job_handle
    type 26 => :option, :option_name

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
