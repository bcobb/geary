Feature: Submit jobs in the foreground

  Scenario: Client submits a job which passes
    Given a file named "client.rb" with:
    """
    require 'gearman'

    client = Gearman::Client.new('localhost:4730')
    client.submit_job(:reverse, 'string') do |job|
      job.on_complete { |data| puts data }
    end
    """
    And a file named "worker.rb" with:
    """
    require 'gearman'

    worker = Gearman::Worker.new('localhost:4730')
    worker.can_do(:reverse) do |data, client|
      data.reverse
    end

    worker.work

    worker.reset_abilities
    """
