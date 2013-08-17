require 'geary/cli' 

require 'thread'

module Geary
  describe CLI do

    it 'shuts down when sent TERM' do
      argv = ['-c 0']
      kernel = double('kernel')
      cli = CLI.new(argv, STDOUT, STDERR, kernel)

      t = Thread.new { cli.execute! }
      t.abort_on_exception = true

      kernel.should_receive(:exit)

      cli.external_signal_queue.puts('TERM')

      t.value
    end

    it 'shuts down when sent INT' do
      argv = ['-c 0']
      kernel = double('kernel')
      cli = CLI.new(argv, STDOUT, STDERR, kernel)

      t = Thread.new { cli.execute! }
      t.abort_on_exception = true

      kernel.should_receive(:exit)

      cli.external_signal_queue.puts('INT')

      t.value
    end

  end
end
