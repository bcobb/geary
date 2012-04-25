require 'gearman'

describe Gearman::Client do

  it 'can send an echo to gearman servers' do
    subject.echo('data').should == 'data'
  end

end
