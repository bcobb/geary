require 'gearman'

describe Gearman::Client do

  it 'can tell the server to echo data' do
    client = Gearman::Client.new
    client.echo('data').should == 'data'
  end

  it 'can submit a job to the server' do
    client = Gearman::Client.new
    job_created = client.submit_job('function', 'id', 'data')
    job_created.should == '1'
  end

end
