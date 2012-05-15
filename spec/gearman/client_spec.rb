require 'gearman'

describe Gearman::Client do

  # XXX: Gearman.configure { }
  subject { Gearman::Client.new }

  # user: client + server(s)
  # client -> tell server to echo data
  #           => grab connection from connection pool
  #           => send request over connection, read response into a generic
  #           response container
  #           => convert response to the expected type
  #           => if conversion fails, read as error
  #           => if can't read as error, raise
  it 'can echo data' do
    subject.echo('data').should == 'data'
  end

end
