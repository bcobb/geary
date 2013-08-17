require 'geary/worker'

module Geary

  describe Worker do

    it 'starts jobs by submitting background Gearman jobs' do
      client = double('Gearman::Client')

      worker = Class.new do
        extend Worker
      end

      worker.stub(:gearman_client) { client }
      client.should_receive(:submit_job_bg).
        with('Geary.default', instance_of(String))

      worker.perform_async
    end

  end

end
