require 'gearman'

describe Gearman::Client do

  let(:server) { stub }

  subject { described_class.new(server) }

  it 'can tell the server to echo data' do
    request = Gearman::Request.new(16, 'data')

    server.should_receive(:send).with(request)

    subject.echo('data')
  end

  it 'can submit a job to the server' do
    request = Gearman::Request.new(7, 'function', '1', 'data')

    server.should_receive(:send).with(request)

    subject.submit_job('function', '1', 'data')
  end

  it 'can submit high priority jobs to the server' do
    request = Gearman::Request.new(21, 'function', '1', 'data')

    server.should_receive(:send).with(request)

    subject.submit_job_high('function', '1', 'data')
  end

  it 'can submit low priority jobs to the server' do
    request = Gearman::Request.new(33, 'function', '1', 'data')

    server.should_receive(:send).with(request)

    subject.submit_job_low('function', '1', 'data')
  end

  it 'can submit a background job to the server' do
    request = Gearman::Request.new(18, 'function', '1', 'data')

    server.should_receive(:send).with(request)

    subject.submit_job_bg('function', '1', 'data')
  end

  it 'can submit a high priority background job to the server' do
    request = Gearman::Request.new(32, 'function', '1', 'data')

    server.should_receive(:send).with(request)

    subject.submit_job_high_bg('function', '1', 'data')
  end

  it 'can submit a low priority background job to the server' do
    request = Gearman::Request.new(34, 'function', '1', 'data')

    server.should_receive(:send).with(request)

    subject.submit_job_low_bg('function', '1', 'data')
  end

  it 'can submit a job to run at a given time' do
    epoch = Time.now.to_i

    request = Gearman::Request.new(36, 'function', '1', epoch, 'data')

    server.should_receive(:send).with(request)

    subject.submit_job_epoch('function', '1', epoch, 'data')
  end

  it 'can get the status of a job' do
    request = Gearman::Request.new(15, 'handle')

    server.should_receive(:send).with(request)

    subject.get_status('handle')
  end

  it 'can set an option on the server' do
    request = Gearman::Request.new(26, 'option_name')

    server.should_receive(:send).with(request)

    subject.set_option('option_name')
  end

end
