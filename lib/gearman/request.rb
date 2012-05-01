module Gearman
  class Request

    MAGIC = "\0REQ"

    def self.type(map, *arguments)
      map.each do |method, type|
        instance_eval %{
          def #{method}(#{arguments.join(", ")})
            Request.new(#{type}, #{arguments.join(", ")})
          end
        }
      end
    end

    type :echo => 16, :data
    type :submit_job => 7, :function_name, :unique_id, :data
    type :submit_job_high => 21, :function_name, :unique_id, :data
    type :submit_job_low => 33, :function_name, :unique_id, :data
    type :submit_job_bg => 18, :function_name, :unique_id, :data
    type :submit_job_high_bg => 32, :function_name, :unique_id, :data
    type :submit_job_low_bg => 34, :function_name, :unique_id, :data
    type :submit_job_epoch => 36, :function_name, :unique_id, :data
    type :get_status => 36, :job_handle
    type :option => 26, :option_name

    def initialize(type, *arguments)
      @packet = Packet.new MAGIC, type, arguments
    end

    def to_s
      Packet.dump(@packet)
    end

    def ==(request)
      request.to_s == to_s
    end

  end
end
