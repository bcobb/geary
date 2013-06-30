require 'geary/worker'

module Geary

  describe Worker do

    it 'starts jobs by submitting background Gearman jobs' do
      channel = double('Gearman::Client::Channel')

      worker = Class.new do
        extend Worker

        use_gearman_channel channel
      end

      channel.should_receive(:submit_job_bg).
        with('Geary.default', instance_of(String))

      worker.perform_async
    end

  end

end
