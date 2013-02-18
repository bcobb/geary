require 'geary'

describe 'a client' do

  let(:client) do
    factory = Geary::Factory.new(:host => 'localhost', :port => 4730)
    client = factory.client
  end

  it 'can issue echo request' do
    packet = client.echo('hello!')

    expect(packet.data).to eql('hello!')
  end

  it 'can submit jobs' do
    packet = client.submit_job(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'can submit high priority jobs' do
    packet = client.submit_job_high(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'can submit low priority jobs' do
    packet = client.submit_job_low(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'can submit background jobs' do
    packet = client.submit_job_bg(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'can submit high priority background jobs' do
    packet = client.submit_job_high_bg(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'can submit low priority background jobs' do
    packet = client.submit_job_low_bg(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'can get the status of jobs in progress' do
    job_created = client.submit_job(:test, 'something')
    status = client.get_status(job_created.job_handle)

    expect(status.job_handle).to eql(job_created.job_handle)
  end

end
