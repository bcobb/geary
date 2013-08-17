require 'gearman/packet/sugar'

module Gearman
  module Packet

    describe Sugar do

      it 'allows classes to create initializers which accept options' do
        class_ = Class.new { extend Sugar ; takes(:foo, :bar) }
        object = class_.new(foo: 'foo', bar: 'bar')

        expect(object.foo).to eql('foo')
        expect(object.bar).to eql('bar')
        expect(object.arguments).to eql(['foo', 'bar'])
      end

      it 'allows classes to create initializers which accept positional arguments' do
        class_ = Class.new { extend Sugar ; takes(:foo, :bar) }
        object = class_.new(['foo', 'bar'])

        expect(object.foo).to eql('foo')
        expect(object.bar).to eql('bar')
        expect(object.arguments).to eql(['foo', 'bar'])
      end

      it 'raises an ArgumentError if given something other than a Hash or an Array' do
        class_ = Class.new { extend Sugar ; takes(:foo, :bar) }

        expect do
          object = class_.new(1)
        end.to raise_error(ArgumentError)
      end

      it 'allows classes to set "numbers" for their instances' do
        class_ = Class.new { extend Sugar ; number 1 }
        object = class_.new

        expect(object.number).to eql(1)
      end

      it 'can create new packet types with ease' do
        type = Sugar.type 'CanDo', takes: [:function_name], number: 1

        expect(type.new(['foo']).function_name).to eql('foo')
        expect(type.new(function_name: 'foo').function_name).to eql('foo')
        expect(type.new(function_name: 'foo').number).to eql(1)
      end

      it 'creates packets with value equality' do
        type = Sugar.type 'CanDo', takes: [:function_name], number: 1

        expect(type.new(['foo'])).to eql(type.new(['foo']))
      end

    end

  end
end
