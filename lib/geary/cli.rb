require 'socket'
require 'timeout'
require 'forwardable'

require 'celluloid'

require 'geary/option_parser'
require 'geary/performer'
require 'geary/manager'

module Geary

  class CLI
    extend Forwardable

    Error = Class.new(StandardError)
    Shutdown = Class.new(Error)

    attr_reader :configuration, :internal_signal_queue, :external_signal_queue

    def initialize(argv, stdout = STDOUT, stderr = STDERR, kernel = Kernel,
                   pipe = IO.pipe)
      @argv = argv
      @stdout = stdout
      @stdout = stderr
      @kernel = kernel
      @internal_signal_queue, @external_signal_queue = pipe
      @configuration = OptionParser.new.parse(@argv)
    end

    def execute!
      %w(INT TERM).each do |signal|
        trap signal do
          external_signal_queue.puts(signal)
        end
      end

      munge_environment_given(configuration)

      manager = Manager.new(configuration)
      manager.start_managing

      begin
        loop do
          IO.select([internal_signal_queue])
          signal = internal_signal_queue.gets.strip

          handle(signal)
        end
      rescue Shutdown
        manager.async.stop_managing

        manager.wait(:shutdown)

        @kernel.exit(0)
      end
    end

    def handle(signal)
      if %w(INT TERM).include?(signal)
        raise Shutdown
      end
    end

    private

    def munge_environment_given(configuration)
      $:.concat(configuration.included_paths)
      configuration.required_files.each { |file| require file }
    end

  end
end
