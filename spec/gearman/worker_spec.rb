require 'gearman/worker'
require 'support/actor_double'

module Gearman

  class FakeConnection
    include Celluloid
  end

  describe Worker do
    include ActorDouble

    let!(:connection) { actor_double }

    it 'expects a NOOP after it sends PRE_SLEEP' do
      connection.stub(:write)
      connection.should_receive(:next).with(Packet::NOOP)

      worker = Worker.new('geraman://localhost:4730')
      worker.configure_connection ->(address) { connection }

      worker.pre_sleep
    end

    it 'expects either a JOB_ASSIGN or a NO_JOB when it grabs a job' do
      connection.stub(:write)
      connection.should_receive(:next).with(Packet::JOB_ASSIGN, Packet::NO_JOB)

      worker = Worker.new('gearman://localhost:4730')
      worker.configure_connection ->(address) { connection }

      worker.grab_job
    end

    it 'sends WORK_EXCEPTION' do
      work_exception = Packet::WORK_EXCEPTION.new(handle: 'h', data: 'd')
      connection.should_receive(:write).with(work_exception)

      worker = Worker.new('gearman://localhost:4730')
      worker.configure_connection ->(address) { connection }

      worker.work_exception('h', 'd')
    end

    it 'sends WORK_COMPLETE' do
      work_complete = Packet::WORK_COMPLETE.new(handle: 'h', data: 'd')
      connection.should_receive(:write).with(work_complete)

      worker = Worker.new('gearman://localhost:4730')
      worker.configure_connection ->(address) { connection }

      worker.work_complete('h', 'd')
    end

    it 'sends CAN_DO' do
      can_do = Packet::CAN_DO.new(function_name: 'ability')

      connection.should_receive(:write).with(can_do)

      worker = Worker.new('gearman://localhost:4730')
      worker.configure_connection ->(address) { connection }

      worker.can_do('ability')
    end

  end

end
