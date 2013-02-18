require_relative 'packet_type_repository/type_not_found'
require_relative 'packet_type_repository/normalization'

module Geary
  class PacketTypeRepository
    include Normalization

    def self.seeded_with(*initial_types)
      initial_types.reduce(new) do |repository, packet_type|
        [packet_type.type, packet_type.packet_name].each do |key|
          repository.store(key, packet_type)
        end

        repository
      end
    end

    def initialize
      @index = {}
    end

    def packet(type, *args)
      find(type).new(*args)
    end

    def store(id, packet_type)
      @index.update(normalize(id) => packet_type)

      self
    end

    def find(id)
      @index.fetch(normalize(id)) do |missing_key|
        raise TypeNotFound,
          "could not find a packet type with type #{missing_key}"
      end
    end

  end
end
