require 'nestegg'

module Geary
  class Error < StandardError
    include Nestegg::NestingException
  end
end
