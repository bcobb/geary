module Geary
  class Client

    attr_reader :packet_stream, :unique_id_generator

    def initialize(options = {})
      @packet_stream = options.fetch(:packet_stream)
      @unique_id_generator = options.fetch(:unique_id_generator)
    end

    def echo(data)
      packet_stream.write(:echo_req, data)

      packet_stream.read
    end

    def submit_job(function_name, data)
      unique_id = unique_id_generator.generate(function_name, data)

      packet_stream.write(:submit_job, function_name, unique_id, data)

      packet_stream.read
    end

  end
end
