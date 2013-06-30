require 'geary/cli'
require 'aruba'
require 'aruba/in_process'

Given(/gearup is running/) do
  Aruba::InProcess.main_class = Geary::CLI
  Aruba.process = Aruba::InProcess
end
