module Geary
  class Railtie < Rails::Railtie

    config.before_initialize do
      Rails.application.paths.add 'app/workers', eager_load: true
    end

  end
end
