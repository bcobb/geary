module Gearman
  class Client

    def echo(data, request_container = Request::EchoReq,
             response_reader = Response::EchoRes)
      Gearman.connect do |server|
        server.request(request_container.new(data))
        response_reader.read_response(server)
      end
    end

  end
end
