require 'geary/option_parser'

module Geary
  describe OptionParser do

    it 'understands comma-delimited servers to mean multiple servers' do
      args = ['-s', 'gearman://localhost:4730,gearman://localhost:4731']
      parser = OptionParser.new

      configuration = parser.parse(args)

      expect(configuration.server_addresses.map(&:to_s)).
        to eql(['gearman://localhost:4730', 'gearman://localhost:4731'])
    end

  end
end
