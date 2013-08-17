require 'gearman/address'

module Gearman
  class Address
    module Serializer

      module_function

      def load(value)
        if value.is_a?(String)
          host, port = value.split(':')
          Address.new(host: host, port: port)
        elsif value.is_a?(Address)
          value
        elsif value
          raise "#{value.inspect} cannot be coerced to an Address"
        end
      end

      def dump(address)
        if address && address.is_a?(Address)
          address.to_s
        end
      end

    end
  end
end
