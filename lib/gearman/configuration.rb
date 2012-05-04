module Gearman
  class Configuration

    def self.add_setting(name, opts={})
      attr_accessor name
      define_predicate_for name
    end

    def self.define_predicate_for(*names)
      names.each {|name| alias_method "#{name}?", name}
    end

    add_setting :connection_pool

  end
end
