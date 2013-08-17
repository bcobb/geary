require 'gearman/address/serializer'

module Gearman
  class Address

    describe Serializer do

      it 'loads "localhost:4730" as an address' do
        address = Serializer.load('localhost:4730')

        expect(address).to eql(Address.new(host: 'localhost', port: 4730))
      end

    end

  end
end
