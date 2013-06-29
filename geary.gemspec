lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

module Geary
  VERSION = '0.0.1'
end

Gem::Specification.new do |s|
  s.name            = "geary"
  s.version         = Geary::VERSION
  s.platform        = Gem::Platform::RUBY
  s.summary         = "Resque/Sidekiq-style Gearman workers"

  s.description     = "An attempt to replace gearman-ruby"

  s.files           = Dir['{lib/**/*}'] + %w(README.markdown)
  s.require_path    = 'lib'
  s.extra_rdoc_files = ['README.markdown']
  s.test_files      = Dir['spec/**/*_spec.rb']

  s.author          = 'Brian Cobb'
  s.email           = 'bcobb@uwalumni.com'
  s.homepage        = 'https://github.com/bcobb/geary'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'cane'
end
