require 'geary'

describe 'a client' do

  it 'can issue echo request' do
    factory = Geary::Factory.new(:host => 'localhost', :port => 4730)
    client = factory.client

    packet = client.echo('hello!')

    expect(packet.data).to eql('hello!')
  end

end
