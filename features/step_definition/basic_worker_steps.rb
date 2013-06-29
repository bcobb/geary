require 'aruba'
require 'aruba/in_process'

Given(/gearup is running/) do
  Aruba::InProcess.main_class = Gearup::CLI
  Aruba.process = Aruba::InProcess
end
