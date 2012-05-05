module Gearman
  class ServerConnection

    def initialize(connection, serializer = Packet)
      @connection = connection
      @serializer = serializer
    end

    def request(request)
      @connection.write(@serializer.dump(request))
    end

    def response
      @serializer.load(@connection)
    end

    def close_connection
      return if @connection.closed?

      @connection.close
    end

  end
end
