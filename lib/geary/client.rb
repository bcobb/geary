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
      submit_job_as(:submit_job, function_name, data)
    end

    def submit_job_high(function_name, data)
      submit_job_as(:submit_job_high, function_name, data)
    end

    def submit_job_low(function_name, data)
      submit_job_as(:submit_job_low, function_name, data)
    end

    def submit_job_bg(function_name, data)
      submit_job_as(:submit_job_bg, function_name, data)
    end

    def submit_job_high_bg(function_name, data)
      submit_job_as(:submit_job_high_bg, function_name, data)
    end

    def submit_job_low_bg(function_name, data)
      submit_job_as(:submit_job_low_bg, function_name, data)
    end

    def submit_job_as(job_type, function_name, data)
      unique_id = unique_id_generator.generate(function_name, data)

      packet_stream.write(job_type, function_name, unique_id, data)

      packet_stream.read
    end

    def get_status(job_handle)
      packet_stream.write(:get_status, job_handle)

      packet_stream.read
    end

    def set_server_option(option_name)
      packet_stream.write(:option_req, option_name)

      packet_stream.read
    end

  end
end
