require 'geary/performer'
require 'support/actor_double'
require 'support/without_logging'
require 'uri'

module Geary
  describe Performer do
    include ActorDouble
    include WithoutLogging

    let(:address) do
      URI('gearman://localhost:4730')
    end

    let(:gearman) { actor_double }

    it 'registers its ability with Gearman' do
      gearman.stub(:grab_job)
      gearman.should_receive(:can_do)

      performer = Performer.new(address)
      performer.configure_connection ->(address) { gearman }

      performer.start
    end

    it 'tries to pop a job off the queue' do
      gearman.stub(:can_do)
      gearman.should_receive(:grab_job)

      performer = Performer.new(address)
      performer.configure_connection ->(address) { gearman }

      performer.start
    end

    it 'sleeps if it gets a NO_JOB' do
      gearman.stub(:can_do)
      gearman.stub(:grab_job).and_return(Gearman::Packet::NO_JOB.new, nil)
      gearman.should_receive(:pre_sleep)

      performer = Performer.new(address)
      performer.configure_connection ->(address) { gearman }

      performer.start
    end

    it 'performs the job if it gets a JOB_ASSIGN' do
      worker_class = Class.new { }
      worker = worker_class.any_instance

      Object.const_set('A', worker_class)

      job = JSON.dump({
        class: 'A',
        args: ['a']
      })

      job_assign = Gearman::Packet::JOB_ASSIGN.new(['h', 'f', job])

      gearman.stub(:can_do)
      gearman.stub(:grab_job).and_return(job_assign, nil)
      gearman.stub(:work_complete)

      worker.should_receive(:perform).with('a')

      performer = Performer.new(address)
      performer.configure_connection ->(address) { gearman }

      performer.start
    end

    it 'sends the result of a job to Gearman' do
      worker_class = Class.new { }
      worker = worker_class.any_instance
      worker.stub(:perform) { 'result' }

      Object.const_set('B', worker_class)

      job = JSON.dump({
        class: 'B',
        args: ['a']
      })

      async_proxy = double('gearman.async')
      job_assign = Gearman::Packet::JOB_ASSIGN.new(['h', 'f', job])

      gearman.stub(:can_do)
      gearman.stub(:grab_job).and_return(job_assign, nil)
      gearman.stub(:async) { async_proxy }
      async_proxy.should_receive(:work_complete).with('h', 'result')

      performer = Performer.new(address)
      performer.configure_connection ->(address) { gearman }

      performer.start
    end

    it 'sends a WORK_EXCEPTION to Gearman if the job raises' do
      worker_class = Class.new { }
      worker = worker_class.any_instance
      worker.stub(:perform).and_raise RuntimeError, "ack!"

      Object.const_set('C', worker_class)

      job = JSON.dump({
        class: 'C',
        args: ['a']
      })

      async_proxy = double('gearman.async')
      job_assign = Gearman::Packet::JOB_ASSIGN.new(['h', 'f', job])

      gearman.stub(:can_do)
      gearman.stub(:grab_job).and_return(job_assign, nil)
      gearman.stub(:async) { async_proxy }
      async_proxy.should_receive(:work_exception).with('h', 'ack!')

      performer = Performer.new(address)
      performer.configure_connection ->(address) { gearman }

      performer.start
    end

    it 'can repair its connection to Gearman'

  end
end
