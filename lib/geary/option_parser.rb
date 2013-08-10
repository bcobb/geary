require 'optparse'

require 'geary/configuration'

module Geary
  class OptionParser

    def parse(args)
      Configuration.new.tap do |configuration|
        parser_which_configures(configuration).parse!(Array(args))
      end
    end

    def parser_which_configures(configuration)
      ::OptionParser.new do |parser|
        parser.on('-s', '--server SERVERS', Array) do |server_addresses|
          configuration.server_addresses = server_addresses
        end

        parser.on('-r', '--require FILES', Array) do |files|
          configuration.required_files = files
        end

        parser.on('-I', '--include PATHS', Array) do |paths|
          configuration.included_paths = paths
        end

        parser.on('-c', '--concurrency NUMBER', 'number of concurrent tasks to run per server') do |number|
          configuration.concurrency = Integer(number)
        end
      end
    end

  end
end
