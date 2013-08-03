require 'virtus'

module Gearman
  class Address
    include Virtus::ValueObject

    attribute :host, String
    attribute :port, Integer

    def to_s
      return @_to_s if @_to_s

      if host && port
        @_to_s = [host, port].join(':')
      else
        @_to_s = ''
      end
    end
    alias :to_str :to_s

  end
end
