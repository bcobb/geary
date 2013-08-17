require 'gearman/packet'

module Gearman
  describe Packet do

    before do
      Packet::Repository.new
    end

    it 'contains a bunch of packet types' do
      %w(CAN_DO PRE_SLEEP NOOP GRAB_JOB NO_JOB JOB_ASSIGN
      WORK_COMPLETE WORK_EXCEPTION).each do |type|
        type = Gearman::Packet.const_get(type)
        arguments = type.const_get('ARGUMENTS').map { 'foo ' }

        expect do
          type.new(arguments)
        end.to_not raise_error
      end
    end
  end
end
