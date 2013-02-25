require 'geary'

describe "the admin client" do

  let(:factory) do
    Geary::Factory.new(:host => 'localhost', :port => 4730)
  end

  let(:admin_client) { factory.admin_client }
  let(:worker_client) { factory.worker_client }
  let(:client) { factory.client }

  after do
    admin_client.connection.close
    worker_client.connection.close
    client.connection.close
  end

  it 'lists workers' do
    worker_client.can_do(:something)
    worker_client.can_do(:something_else)

    client.submit_job(:something, '')

    workers = admin_client.workers
    registered_functions = workers.map(&:function_names).flatten

    expect(workers).to_not be_empty
    expect(registered_functions).to include('something')
  end

  it 'gets registered functions' do
    worker_client.can_do(:something)
    worker_client.can_do(:something_else)

    functions = admin_client.status

    function_names = functions.map(&:name)

    expect(function_names).to include('something')
    expect(function_names).to include('something_else')
  end

  it 'reads the server version' do
    version = admin_client.server_version

    expect(version).to_not be_nil
  end

  it 'can shut down the server' do
    packet_stream = double('PacketStream')
    admin_client = Geary::AdminClient.new(:packet_stream => packet_stream)

    packet_stream.should_receive(:write).with('shutdown')

    admin_client.shutdown
  end

  it 'can shut down the server gracefully' do
    packet_stream = double('PacketStream')
    admin_client = Geary::AdminClient.new(:packet_stream => packet_stream)

    packet_stream.should_receive(:write).with('shutdown graceful')

    admin_client.shutdown(true)
  end

end
