require 'virtus'

require 'gearman/address'
require 'gearman/address/serializer'

module Geary
  class Configuration
    include Virtus

    class AddressWriter < Virtus::Attribute::Writer::Coercible

      def coerce(values)
        if values.is_a?(Array)
          values.map { |value| Gearman::Address::Serializer.load(value) }
        else
          Gearman::Address::Serializer.load(value)
        end
      end

    end

    attribute :server_addresses, Array[Gearman::Address], default: ['localhost:4730'],
      writer_class: AddressWriter
    attribute :concurrency, Integer, default: ->(*) { Celluloid.cores }, lazy: true
    attribute :included_paths, Array, default: %w(.)
    attribute :required_files, Array, default: []

  end
end
