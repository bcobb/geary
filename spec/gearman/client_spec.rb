require 'gearman/client'

module Gearman
  describe Client do

    it 'submits background jobs' do
      expected_packet = Packet::SUBMIT_JOB_BG.new(
        function_name: 'super_ability',
        unique_id: 'UUID',
        data: 'data'
      )

      connection = double('Connection')
      connection.should_receive(:write).with(expected_packet)
      connection.stub_chain(:async, :next)

      client = Client.new('localhost:4730')
      client.generate_unique_id_with { 'UUID' }
      client.configure_connection { connection }

      client.submit_job_bg('super_ability', 'data')
    end

  end
end
