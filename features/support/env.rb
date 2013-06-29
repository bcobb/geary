require 'aruba/cucumber'

Before do
  # Instruct Aruba to perform file operations in features/tmp
  @dirs = ["features/tmp"]
end
