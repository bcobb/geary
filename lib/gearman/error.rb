require 'nestegg'

module Gearman
  class Error < StandardError
    include Nestegg::NestingException
  end
end
