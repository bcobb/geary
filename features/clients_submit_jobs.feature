Feature: Clients submit jobs

  Scenario: Client submits a background job with no data
    Given a file named "client.rb" with the following contents: 
    """
    require 'gearman'

    client = Gearman::Client.new('localhost:4730')
    job = client.submit_job_bg :test
    job.known?
    job.running?
    job.percent_complete
    job.complete?
    """
    And a file named "worker.rb" with the following contents:
    """
    require 'gearman'

    worker = Gearman::Worker.new('localhost:4730')
    worker.can_do :test do |data, work|
      true
    end
    """
