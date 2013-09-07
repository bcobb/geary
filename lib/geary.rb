require 'geary/worker'

module Geary
end

if defined?(Rails)
  require 'geary/railtie'
end
