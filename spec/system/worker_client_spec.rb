require 'geary'

describe "a worker's client" do

  let(:factory) do
    Geary::Factory.new(:host => 'localhost', :port => 4730)
  end

  let(:client) { factory.client }
  let(:worker) { factory.worker_client }

  after do
    client.packet_stream.connection.close
    worker.packet_stream.connection.close
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

  it 'can grab a job and get its unique id' do
    random = Time.now.to_i.to_s + rand.to_s
    fake_generator = double('Generator', :generate => random)
    client = factory.client(:unique_id_generator => fake_generator)

    worker.can_do(:job_that_cares_about_uniqe_ids)
    client.submit_job(:job_that_cares_about_uniqe_ids, 'cool!')

    assigned_job = worker.grab_job_uniq

    expect(assigned_job.unique_id).to eql(random)
  end

  it 'can send an update on status' do
    worker.can_do(:long_running_sends_status)
    client_job = client.submit_job(:long_running_sends_status, 'data')
    worker_job = worker.grab_job
    worker.send_work_status(worker_job.job_handle, 0.5)

    # XXX: get_status should read _until_ status_res
    status_packet = client.packet_stream.read

    client_status = client.get_status(client_job.job_handle)

    expect(client_status.percent_complete).to eql(0.5)
  end

  it 'can update status to 100% complete' do
    worker.can_do(:long_running_sends_status)
    client_job = client.submit_job(:long_running_sends_status, 'data')
    worker_job = worker.grab_job
    worker.send_work_status(worker_job.job_handle, 1)

    # XXX: get_status should read _until_ status_res
    status_packet = client.packet_stream.read

    client_status = client.get_status(client_job.job_handle)

    expect(client_status).to be_complete
  end

  it 'can send data on completion' do
    worker.can_do(:long_running_will_complete)
    client_job = client.submit_job(:long_running_will_complete, 'data')

    worker_job = worker.grab_job
    worker.send_work_complete(worker_job.job_handle, 'complete')

    work_complete = client.packet_stream.read

    expect(work_complete.data).to eql('complete')
  end

  it 'can send failure notices' do
    worker.can_do(:long_running_will_fail)
    client_job = client.submit_job(:long_running_will_fail, 'data')

    worker_job = worker.grab_job
    worker.send_work_fail(worker_job.job_handle)

    work_fail = client.packet_stream.read

    expect(work_fail).to be_a(Geary::Packet::WorkFailResponse)
  end

  it 'can send exception notices' do
    client.set_server_option('exceptions')

    worker.can_do(:long_running_will_raise)
    client_job = client.submit_job(:long_running_will_raise, 'data')

    worker_job = worker.grab_job
    worker.send_work_exception(worker_job.job_handle, 'oh no!')

    work_exception = client.packet_stream.read

    expect(work_exception.data).to eql('oh no!')
  end

  it 'can send work data' do
    worker.can_do(:long_running_will_send_data)
    client_job = client.submit_job(:long_running_will_send_data, 'data')

    worker_job = worker.grab_job
    worker.send_work_data(worker_job.job_handle, 'woo!')

    work_data = client.packet_stream.read

    expect(work_data.data).to eql('woo!')
  end

  it 'can send work warnings' do
    worker.can_do(:long_running_will_warn)
    client_job = client.submit_job(:long_running_will_warn, 'data')

    worker_job = worker.grab_job
    worker.send_work_warning(worker_job.job_handle, 'watch out!')

    work_warning = client.packet_stream.read

    expect(work_warning.data).to eql('watch out!')
  end

end
