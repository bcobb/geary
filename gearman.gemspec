lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'gearman/version'

Gem::Specification.new do |s|
  s.name            = "gearman-ruby"
  s.version         = Gearman::VERSION
  s.platform        = Gem::Platform::RUBY
  s.summary         = "Gearman client and workers in Ruby"

  s.description     = <<-DESC
Gearman is a job processing system for sexy people.
DESC

  s.files           = Dir['{bin/*,lib/**/*}'] + %w(README.md)
  s.require_path    = 'lib'
  s.extra_rdoc_files = ['README.md']
  s.test_files      = Dir['spec/**/*_spec.rb']

  s.author          = 'Brian Cobb'
  s.email           = 'b@bcobb.net'
  s.homepage        = 'https://github.com/bcobb/gearman-ruby'

  s.add_development_dependency 'rspec'
  s.add_dependency 'nestegg'
end

