Feature: Basic Worker

  Geary runs a process which processes background jobs.

  Scenario: run `gearup` with no additional configuration
    Given a file named "lib/hard_worker.rb" with:
      """
      require 'geary/worker'

      class HardWorker
        extend Geary::Worker

        def perform(file_location)
          File.open(file_location, 'w+') do |f|
            f.puts 'HardWorker was here'
          end
        end

      end
      """
    And a file named "app.rb" with:
      """
        require_relative 'lib/hard_worker'

        def main(*args)
          file_location, _ = args

          HardWorker.perform_async(file_location)
        end

        main(ARGV.dup)
      """
    When I successfully run `ruby app.rb out`
    And geary runs with the flags "-rhard_worker -Ilib -c1"
    Then the file "out" should eventually contain:
      """
      HardWorker was here
      """
