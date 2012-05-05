module Gearman
  class Client

    def echo(data)
      Gearman.connect do |server|
        server.request(Request.echo_req(data))
        response = server.response
      end
    end

  end
end
