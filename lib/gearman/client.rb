module Gearman
  class Client

    REQUESTS = {
      :echo => 16,
      :submit_job => 7,
      :submit_job_high => 21,
      :submit_job_low => 33,
      :submit_job_bg => 18,
      :submit_job_high_bg => 32,
      :submit_job_low_bg => 34,
      :submit_job_epoch => 36,
      :get_status => 15,
      :set_option => 26
    }

    def initialize(server)
      @server = server
    end

    def self.can(name, args = [])
      return if args.empty?

      type = REQUESTS.fetch(name) { name }
      class_eval %{
        def #{name}(#{args.join(", ")})
          request = Request.new(#{type}, #{args.join(", ")})
          @server.send(request)
        end
      }
    end
    private_class_method :can

    can :echo, [:data]
    can :submit_job, [:job, :job_id, :data]
    can :submit_job_high, [:job, :job_id, :data]
    can :submit_job_low, [:job, :job_id, :data]
    can :submit_job_bg, [:job, :job_id, :data]
    can :submit_job_high_bg, [:job, :job_id, :data]
    can :submit_job_low_bg, [:job, :job_id, :data]
    can :submit_job_epoch, [:job, :job_id, :epoch_time, :data]
    can :get_status, [:job_handle]
    can :set_option, [:option_name]

  end
end
