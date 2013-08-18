require 'gearman_admin_client'
require 'gearmand_control'
require 'gearman/packet'
require 'geary/manager'
require 'geary/worker'

describe 'running 20K jobs' do

  class TestWorker
    extend Geary::Worker

    def perform
    end
  end

  it 'takes some amount of time' do
    admin = GearmanAdminClient.new('localhost:4730')

    configuration = Geary::Configuration.new(concurrency: 25)
    manager = Geary::Manager.new(configuration: configuration)

    n = 20_000
    n.times { TestWorker.perform_async }

    expect(admin.status.first.jobs_in_queue).to eql(n)

    start = Time.now
    stop = Time.now
    stop_candidate = Time.now
    manager.async.start

    loop do
      stop_candidate = Time.now
      sleep 1

      if admin.status.first.jobs_in_queue.zero?
        stop = Time.now
        break
      end
    end

    puts "Between #{stop_candidate.to_f - start.to_f} and #{stop.to_f - start.to_f}"
  end

end
