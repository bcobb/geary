require 'digest/sha1'

module Gearman
  class Client

    def echo(data)
      Gearman.connect do |server|
        server.request(Request.echo_req(data))
        response = Response.echo_res(server.response)
        response.data
      end
    end

    def submit_job(function_name, data, options = {})
      priority = options[:priority] || nil
      background = options[:background] ? 'bg' : nil

      type = ['submit_job', priority, background].compact.join('_')
      request = Request.method(type)
      unique_id = Digest::SHA1.hexdigest(type + data)

      Gearman.connect do |server|
        server.request(request.call(function_name, unique_id, data))
        Response.job_created(server.response)
      end
    end

    def get_status(job_handle)
      Gearman.connect do |server|
        server.request(Request.get_status(job_handle))
        Response.get_status(server.response)
      end
    end

  end
end
