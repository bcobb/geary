require_relative 'packet_type_repository/errors'
require_relative 'packet_type_repository/normalization'

module Geary
  class PacketTypeRepository
    include Normalization

    def initialize
      @index = {}
    end

    def store(magic, id, packet_type)
      @index[magic] ||= {}
      @index[magic].update(normalize(id) => packet_type)

      self
    end

    def find(magic, id)
      magic_index = @index.fetch(magic) do |missing_magic|
        raise MagicNotFound,
          "could not find the magic code #{missing_magic}"
      end

      magic_index.fetch(normalize(id)) do |missing_key|
        raise TypeNotFound,
          "could not find a #{magic} packet with type #{missing_key}"
      end
    end

  end
end
