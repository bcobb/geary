require 'gearmand_control'
require 'gearman_admin_client'

require 'gearman/client/channel'

module Gearman
  module Client

    describe Channel do

      before do
        @gearmand = GearmandControl.new(4730)
        @gearmand.start
      end

      after do
        @gearmand.stop
      end

      it 'submits background jobs' do
        admin = GearmanAdminClient.new(@gearmand.address)
        channel = Channel.new(@gearmand.address)

        job_created = channel.submit_job_bg('gearman.channel.test')

        expect(admin.status.map(&:name)).to include('gearman.channel.test')
      end

    end

  end
end
