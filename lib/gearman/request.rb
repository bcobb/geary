module Gearman

  class Request
    extend Packet::Factory

    MAGIC = "\0REQ"

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

    def to_s(serializer = Packet)
      serializer.dump(@packet)
    end

    def ==(request)
      request.to_s == to_s
    end

  end
end
