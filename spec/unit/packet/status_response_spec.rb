require 'geary/packet/all'

module Geary::Packet

  describe StatusResponse do

    context 'without any other data' do

      it 'is 0% complete' do
	packet = StatusResponse.new

	expect(packet.percent_complete).to eql(0.0)
      end

      it 'is unknown' do
	packet = StatusResponse.new

	expect(packet).to_not be_known
      end

      it 'is not running' do
	packet = StatusResponse.new

	expect(packet).to_not be_running
      end

    end

    it 'can be known, but not running' do
      arguments = ['job_handle', 1, 0, 0, 0]

      packet = StatusResponse.new(:arguments => arguments)

      expect(packet).to be_known
      expect(packet).to_not be_running
      expect(packet).to_not be_complete
    end

    it 'can be known, running, but not complete' do
      arguments = ['job_handle', 1, 1, 0, 0]

      packet = StatusResponse.new(:arguments => arguments)

      expect(packet).to be_known
      expect(packet).to be_running
      expect(packet).to_not be_complete
    end

    it 'can be known, running, and partially complete' do
      arguments = ['job_handle', 1, 1, 50, 100]

      packet = StatusResponse.new(:arguments => arguments)

      expect(packet).to be_known
      expect(packet).to be_running
      expect(packet).to_not be_complete
      expect(packet.percent_complete).to eql(0.5)
    end

    it 'can be complete' do
      arguments = ['job_handle', 1, 1, 100, 100]

      packet = StatusResponse.new(:arguments => arguments)

      expect(packet).to be_known
      expect(packet).to be_running
      expect(packet).to be_complete
      expect(packet.percent_complete).to eql(1.0)
    end

  end

end
