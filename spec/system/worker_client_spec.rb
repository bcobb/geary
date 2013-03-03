require 'geary'

describe "a worker's client" do

  let(:factory) do
    Geary::Factory.new(:host => 'localhost', :port => 4730)
  end

  let(:client) { factory.client }
  let(:worker) { factory.worker_client }
  let(:admin_client) { factory.admin_client }

  after do
    client.connection.close
    worker.connection.close
    admin_client.connection.close
  end

  it 'grabs jobs once it registers abilities' do
    submitted_job = client.submit_job(:grab_job_test, 'something')
    worker.can_do(:grab_job_test)

    grabbed_job = worker.grab_job

    expect(grabbed_job.job_handle).to eql(submitted_job.job_handle)
  end

  it 'gets NO_JOB if there are no jobs to grab' do
    worker.can_do(:no_job_test)

    grabbed_job = worker.grab_job

    expect(grabbed_job).to be_a(Geary::Packet::NoJob)
  end

  it 'gets NO_JOB if there are jobs but it cannot do any of them' do
    worker.can_do(:cant_do_test)
    client.submit_job(:cant_do_test, 'data')
    worker.cant_do(:cant_do_test)

    expect(worker.grab_job).to be_a(Geary::Packet::NoJob)
  end

  it 'gets NO_JOB if there jobs after it has reset its abilities' do
    worker.can_do(:cant_do_test)
    client.submit_job(:cant_do_test, 'data')
    worker.reset_abilities

    expect(worker.grab_job).to be_a(Geary::Packet::NoJob)
  end

  it 'gets a NOOP if it checks after a PRE_SLEEP and there is a job waiting' do
    worker.can_do(:job_after_sleep)
    worker.pre_sleep
    client.submit_job(:job_after_sleep, 'wake up!')

    expect(worker).to have_jobs_waiting
  end

  it 'does not have jobs waiting if none have been submitted' do
    worker.can_do(:job_that_doesnt_exist)
    worker.pre_sleep

    expect(worker).to_not have_jobs_waiting
  end

  it 'grabs a job and get its unique id' do
    random = Time.now.to_i.to_s + rand.to_s
    fake_generator = double('Generator', :generate => random)
    client = factory.client(:unique_id_generator => fake_generator)

    worker.can_do(:job_that_cares_about_uniqe_ids)
    client.submit_job(:job_that_cares_about_uniqe_ids, 'cool!')

    assigned_job = worker.grab_job_uniq

    expect(assigned_job.unique_id).to eql(random)
  end

  it 'sends an update on status' do
    client_job = client.submit_job(:long_running_sends_status, 'data')

    worker.can_do(:long_running_sends_status)
    worker.grab_job.tap do |job|
      worker.send_work_status(job.job_handle, 0.5)
    end

    status_packet = client.connection.read_response

    client_status = client.get_status(client_job.job_handle)

    expect(client_status.percent_complete).to eql(0.5)
  end

  it 'updates status to 100% complete' do
    client_job = client.submit_job(:long_running_sends_status, 'data')

    worker.can_do(:long_running_sends_status)
    worker.grab_job.tap do |job|
      worker.send_work_status(job.job_handle, 1)
    end

    status_packet = client.connection.read_response

    client_status = client.get_status(client_job.job_handle)

    expect(client_status).to be_complete
  end

  it 'sends data on completion' do
    client_job = client.submit_job(:long_running_will_complete, 'data')

    worker.can_do(:long_running_will_complete)
    worker.grab_job.tap do |job|
      worker.send_work_complete(job.job_handle, 'complete')
    end

    work_complete = client.connection.read_response

    expect(work_complete.data).to eql('complete')
  end

  it 'sends failure notices' do
    client_job = client.submit_job(:long_running_will_fail, 'data')

    worker.can_do(:long_running_will_fail)
    worker.grab_job.tap do |job|
      worker.send_work_fail(job.job_handle)
    end

    work_fail = client.connection.read_response

    expect(work_fail).to be_a(Geary::Packet::WorkFailResponse)
  end

  it 'sends exception notices' do
    client.set_server_option('exceptions')
    client_job = client.submit_job(:long_running_will_raise, 'data')

    worker.can_do(:long_running_will_raise)
    worker.grab_job.tap do |job|
      worker.send_work_exception(job.job_handle, 'oh no!')
    end

    work_exception = client.connection.read_response

    expect(work_exception.data).to eql('oh no!')
  end

  it 'sends work data' do
    client_job = client.submit_job(:long_running_will_send_data, 'data')

    worker.can_do(:long_running_will_send_data)
    worker.grab_job.tap do |job|
      worker.send_work_data(job.job_handle, 'woo!')
    end

    work_data = client.connection.read_response

    expect(work_data.data).to eql('woo!')
  end

  it 'sends work warnings' do
    client_job = client.submit_job(:long_running_will_warn, 'data')

    worker.can_do(:long_running_will_warn)
    worker.grab_job.tap do |job|
      worker.send_work_warning(job.job_handle, 'watch out!')
    end

    work_warning = client.connection.read_response

    expect(work_warning.data).to eql('watch out!')
  end

  it 'set its client id' do
    random = Time.now.to_i.to_s + rand.to_s
    id = "worker-with-id-#{random}"

    worker.set_client_id(id)
    worker.can_do(:hi_mom)

    observed_worker = admin_client.workers.find do |worker|
      worker.client_id == id
    end

    expect(observed_worker).to_not be_nil
  end

  it 'optionally sets a timeout when it registers abilities' do
    pending "Investigation as to how the timeout is triggered"

    job = client.submit_job(:timeout_ability, 'failure!')
    worker.can_do_timeout(:timeout_ability, 1)
    worker.grab_job

    status_packet = client.connection.read_response

    expect(status_packet).to be_a(Geary::Packet::WorkFailResponse)
  end

end
