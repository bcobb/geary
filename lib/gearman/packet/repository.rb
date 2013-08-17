require 'gearman/packet/sugar'

module Gearman
  module Packet
    class Repository

      def initialize
        @by_number = {}
        store(1, 'CAN_DO', [:function_name])
        store(2, 'CANT_DO', [:function_name])
        store(4, 'PRE_SLEEP')
        store(6, 'NOOP')
        store(8, 'JOB_CREATED', [:handle])
        store(9, 'GRAB_JOB')
        store(10, 'NO_JOB')
        store(11, 'JOB_ASSIGN', [:handle, :function_name, :data])
        store(13, 'WORK_COMPLETE', [:handle, :data])
        store(18, 'SUBMIT_JOB_BG', [:function_name, :unique_id, :data])
        store(25, 'WORK_EXCEPTION', [:handle, :data])
      end

      def store(number, type, takes = [])
        Sugar.type(type, number: number, takes: takes).tap do |packet_type|
          @by_number[number] = packet_type
        end
      end

      def load(number)
        @by_number[number]
      end

    end
  end
end
