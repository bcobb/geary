require 'gearman'
require 'tempfile'

describe Gearman::Stream do

  let(:stream) { Tempfile.new('Gearman::Stream') }

  subject { described_class.new(stream) }

  after { stream.close }

  it 'writes strings to IO streams' do
    subject.write('hello')

    stream.rewind
    stream.read.should include 'hello'
  end

  it 'reads IO streams up to a specified length' do
    stream.write('hello')
    stream.rewind

    subject.read(5).should == 'hello'
  end

  it 'can close the IO stream' do
    stream.should_not be_closed

    subject.close

    stream.should be_closed
  end

end
