require 'geary'

describe 'a client' do

  it 'can issue echo request' do
    factory = Geary::Factory.new(:host => 'localhost', :port => 4730)
    client = factory.client

    packet = client.echo('hello!')

    expect(packet.data).to eql('hello!')
  end

  it 'can submit jobs' do
    factory = Geary::Factory.new(:host => 'localhost', :port => 4730)
    client = factory.client

    packet = client.submit_job(:test, 'something')

    expect(packet.job_handle).to_not be_nil
  end

end
