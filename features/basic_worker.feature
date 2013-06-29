Feature: Basic Worker

  Geary runs a process which processes background jobs.

  Scenario: run `gearup` with no additional configuration
    Given the following worker exists at "lib/hard_worker.rb":
      """
      require 'geary/worker'

      class HardWorker
        include Geary::Worker

        def perform(file_location)
          File.open(file_location, 'w+') do |f|
            f.puts 'HardWorker was here'
          end
        end

      end
      """
    And my application looks like:
      """
        require 'lib/hard_worker'

        def main(args)
          file_location, _ = Array(args)

          HardWorker.perform_async(file_location)
        end

        main(ARGV.dup)
      """
    And gearup is running
    When I run my application with "tmp/out"
    Then the file "tmp/out" should contain:
      """
      HardWorker was here
      """
    

