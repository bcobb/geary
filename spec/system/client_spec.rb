require 'geary'

describe 'a client' do

  let(:client) do
    factory = Geary::Factory.new(:host => 'localhost', :port => 4730)
    client = factory.client
  end

  it 'issues echo requests' do
    packet = client.echo('hello!')

    expect(packet.data).to eql('hello!')
  end

  it 'submits jobs' do
    packet = client.submit_job(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'submits high priority jobs' do
    packet = client.submit_job_high(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'submits low priority jobs' do
    packet = client.submit_job_low(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'submits background jobs' do
    packet = client.submit_job_bg(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'submits high priority background jobs' do
    packet = client.submit_job_high_bg(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'submits low priority background jobs' do
    packet = client.submit_job_low_bg(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

  it 'gets the status of jobs in progress' do
    job_created = client.submit_job(:test, 'something')
    status = client.get_status(job_created.job_handle)

    expect(status.job_handle).to eql(job_created.job_handle)
  end

  it 'returns an unknown job when getting the status of a bad job handle' do
    response = client.get_status('bad.job.handle')

    expect(response).to be_unknown
  end

  it 'sets options on the server' do
    option_res = client.set_server_option('exceptions')

    expect(option_res.option_name).to eql('exceptions')
  end

  it 'returns an error when setting an invalid option' do
    option_res = client.set_server_option('unknown_option_i_made_up')

    expect(option_res).to be_a(Geary::Packet::Error)
  end

end
