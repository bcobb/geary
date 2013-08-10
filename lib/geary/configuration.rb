require 'mono_logger'
require 'virtus'

require 'geary/address'

module Geary
  class Configuration
    include Virtus

    class AddressWriter < Virtus::Attribute::Writer::Coercible

      def coerce(values)
        if values.is_a?(Array)
          values.map { |value| coerce_member(value) }
        else
          coerce_member(values)
        end
      end

      def coerce_member(value)
        if value.is_a?(String)
          host, port = value.split(':')
          Address.new(host: host, port: port)
        elsif value.is_a?(Address)
          value
        elsif value
          raise "#{value.inspect} cannot be coerced to an Address"
        end
      end

    end

    attribute :server_addresses, Array[Address], default: ['localhost:4730'],
      writer_class: AddressWriter
    attribute :concurrency, Integer, default: ->(*) { Celluloid.cores }, lazy: true
    attribute :included_paths, Array, default: %w(.)
    attribute :required_files, Array, default: []

  end
end
