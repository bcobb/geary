require 'gearman/client'
require 'support/fake_server'

module Gearman
  describe Client do

    let!(:address) { Address.new(host: '127.0.0.1', port: 4730) }
    let!(:gearmand) { FakeServer.new(address) }

    before do
      gearmand.async.run
      gearmand.wait :accept
    end

    after { gearmand.shutdown }

    it 'submits background jobs' do
      gearmand.respond_with(Packet::JOB_CREATED.new(['handle']))

      expected_packet = Packet::SUBMIT_JOB_BG.new(
        function_name: 'super_ability',
        unique_id: 'UUID',
        data: 'data'
      )

      client = Client.new(address)
      client.generate_unique_id_with -> { 'UUID' }

      client.submit_job_bg('super_ability', 'data')

      expect(gearmand.packets_read.last).to eql(expected_packet)
    end

  end
end
