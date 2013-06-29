Given(/^the following worker exists at "(.*?)":$/) do |location, worker|
  write_file(location, worker)
end
