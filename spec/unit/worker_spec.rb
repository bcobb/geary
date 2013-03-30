require 'geary/worker'

describe 'a worker' do

  it 'satisifies the basic Sidekiq/Resque contract' do
    ContractWorks = Geary::Worker.new(:client => stub('Geary::Client'))

    class TestWorker
      include ContractWorks
    end

    expect(TestWorker).to respond_to(:perform_async)
    expect(TestWorker).to respond_to(:perform_in)
  end

  it 'submits a background job when performing async' do
    client = double("Geary::WorkerClient")
    BackgroundWorks = Geary::Worker.new(:client => client)

    class TestWorker
      include BackgroundWorks
    end

    client.should_receive(:submit_job_bg).with(
      'default',
      { :class => 'TestWorker', :args => [1, 2, 3] }
    )

    TestWorker.perform_async(1, 2, 3)
  end

  describe '.perform_in' do

    it 'schedules the job at the given time if given a future time' do
      client = double("Geary::WorkerClient")
      ScheduledWorks = Geary::Worker.new(:client => client)

      class TestWorker
        include ScheduledWorks
      end

      at = Time.now + 10

      client.should_receive(:submit_job_sched).with(
        'default',
        at.strftime('%-M').to_i,
        at.strftime('%-H').to_i,
        at.strftime('%-d').to_i,
        at.strftime('%-m').to_i,
        (at.strftime('%w').to_i - 1), 
        {
          :class => 'TestWorker',
          :args => [1, 2, 3]
        }
      )

      TestWorker.perform_in(at, 1, 2, 3)
    end

    it 'schedules a job a number of seconds in the future otherwise' do
      client = double("Geary::WorkerClient")
      ScheduledSoonWorks = Geary::Worker.new(:client => client)

      class TestWorker
        include ScheduledSoonWorks
      end

      at = 10
      future = Time.now + 10

      client.should_receive(:submit_job_sched).with(
        'default',
        future.strftime('%-M').to_i,
        future.strftime('%-H').to_i,
        future.strftime('%-d').to_i,
        future.strftime('%-m').to_i,
        (future.strftime('%w').to_i - 1),
        {
          :class => 'TestWorker',
          :args => [1, 2, 3]
        }
      )

      TestWorker.perform_in(at, 1, 2, 3)
    end

  end

end
