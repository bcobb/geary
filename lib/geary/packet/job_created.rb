require_relative 'response'

module Geary
  module Packet
    class JobCreated < Response

      def self.type
        8
      end

      def self.packet_name
        'JOB_CREATED'
      end

      def job_handle
        arguments.first
      end

    end
  end
end
