require 'virtus'

module Geary
  class Address
    include Virtus::ValueObject

    attribute :host, String
    attribute :port, Integer

    def to_sym
      to_s.to_sym
    end

    def to_s
      if host
        [host, port].compact.join(':')
      else
        ''
      end
    end

  end
end
