module Geary
  class PacketTypeRepository

    module Normalization
      
      def normalize(id)
        id.to_s.downcase
      end

    end

  end
end

