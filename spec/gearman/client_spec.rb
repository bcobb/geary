require 'gearman'

describe Gearman::Client do

  it 'can tell the server to echo data' do
    client = Gearman::Client.new
    client.echo('data').should == 'data'
  end

end
