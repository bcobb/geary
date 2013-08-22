require 'geary/cli' 

require 'thread'
require 'timeout'

module Geary
  describe CLI do

    it 'shuts down when sent TERM' do
      kernel = double('kernel')
      kernel.should_receive(:exit)
      argv = ['-c 0']
      cli = CLI.new(argv, STDOUT, STDERR, kernel)

      t = Thread.new { cli.execute! }
      t.abort_on_exception = true

      cli.external_signal_queue.puts('TERM')

      Timeout.timeout(1, StandardError) { t.value } rescue nil
    end

    it 'shuts down when sent INT' do
      kernel = double('kernel')
      kernel.should_receive(:exit)

      argv = ['-c 0']
      cli = CLI.new(argv, STDOUT, STDERR, kernel)

      t = Thread.new { cli.execute! }
      t.abort_on_exception = true

      IO.select([], [cli.external_signal_queue])
      cli.external_signal_queue.puts('INT')

      Timeout.timeout(1, StandardError) { t.value } rescue nil
    end

  end
end
