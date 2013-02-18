require_relative 'request'

module Geary
  module Packet
    class SubmitJob < Request

      def self.type
        7
      end

      def self.packet_name
        'SUBMIT_JOB'
      end

      def data
        arguments.first
      end

    end
  end
end
