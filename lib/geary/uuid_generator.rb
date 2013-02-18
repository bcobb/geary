require 'securerandom'

module Geary
  class UUIDGenerator

    def generate(*args)
      SecureRandom.uuid
    end

  end
end
