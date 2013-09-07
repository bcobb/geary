require 'logger'
require 'virtus'
require 'virtus/uri'

module Geary
  class Configuration
    include Virtus

    attribute :server_addresses, Array[URI], default: ['gearman://localhost:4730']
    attribute :concurrency, Integer, default: 25
    attribute :included_paths, Array, default: %w(.)
    attribute :required_files, Array, default: []
    attribute :failure_monitor_interval, Integer, default: 1
    attribute :jitter, Float, default: 0.01
    attribute :log_level, Object, default: Logger::INFO

  end
end
