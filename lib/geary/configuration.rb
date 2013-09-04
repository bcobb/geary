require 'virtus'
require 'virtus/uri'

module Geary
  class Configuration
    include Virtus

    attribute :server_addresses, Array[URI], default: ['gearman://localhost:4730']
    attribute :concurrency, Integer, default: ->(*) { Celluloid.cores }, lazy: true
    attribute :included_paths, Array, default: %w(.)
    attribute :required_files, Array, default: []
    attribute :failure_monitor_interval, Integer, default: 1

  end
end
