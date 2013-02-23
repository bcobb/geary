require 'geary'

describe "a worker's client" do

  let(:factory) do
    Geary::Factory.new(:host => 'localhost', :port => 4730)
  end

  let(:client) { factory.client }
  let(:worker) { factory.worker_client }

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

end
