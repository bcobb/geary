lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'geary/version'

Gem::Specification.new do |s|
  s.name            = "geary"
  s.version         = Geary::VERSION
  s.platform        = Gem::Platform::RUBY
  s.summary         = "Gearman client and workers in Ruby"

  s.description     = "An attempt to replace gearman-ruby"

  s.files           = Dir['{lib/**/*}'] + %w(README.md)
  s.require_path    = 'lib'
  s.extra_rdoc_files = ['README.md']
  s.test_files      = Dir['spec/**/*_spec.rb']

  s.author          = 'Brian Cobb'
  s.email           = 'b@bcobb.net'
  s.homepage        = 'https://github.com/bcobb/geary'

  s.add_development_dependency 'rspec'
end
