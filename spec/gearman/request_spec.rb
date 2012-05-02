require 'gearman'

describe Gearman::Request do

  it 'can create echo requests' do
    packet = Gearman::Request.echo 'data'
    packet.should be_echo
  end

end
