require 'geary/cli' 

module Geary
  describe CLI do

    it 'starts a worker group for each gearman server' do
      harness = double('Harness')
      harness.should_receive(:new_group).exactly(2).times

      cli = CLI.new(['-s', 'localhost:4730,localhost:4731'])
      cli.execute!
    end

  end
end
