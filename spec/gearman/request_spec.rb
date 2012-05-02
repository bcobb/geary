require 'gearman'

describe Gearman::Request do

  it 'can create echo_req requests' do
    request = described_class.echo_req 'data'
    request.should == described_class.new(16, 'data')
  end

  {
    :submit_job => 7,
    :submit_job_bg => 18,
    :submit_job_low => 33,
    :submit_job_low_bg => 34,
    :submit_job_high => 21,
    :submit_job_high_bg => 32 
  }.each do |submit_job_type, number|

    it "can create #{submit_job_type} requests" do
      request = described_class.send(submit_job_type, 'job', 'id', 'data')
      request.should == described_class.new(number, 'job', 'id', 'data')
    end

  end

  it 'can create submit_job_epoch requests' do
    request = described_class.submit_job_epoch('job', 'id', 'time', 'data')
    request.should == described_class.new(36, 'job', 'id', 'time', 'data')
  end

  it 'can create submit_job_sched requests' do
    request = described_class.submit_job_sched('job', 'id', 'min', 'hour',
                                               'mday', 'month', 'wday', 'data')
    request.should == described_class.new(35, 'job', 'id', 'min', 'hour',
                                          'mday', 'month', 'wday', 'data')
  end

  it 'can create get_status requests' do
    request = described_class.get_status('job_handle')
    request.should == described_class.new(15, 'job_handle')
  end

  it 'can create option_req requests' do
    request = described_class.option_req('option_name')
    request.should == described_class.new(26, 'option_name')
  end

end
