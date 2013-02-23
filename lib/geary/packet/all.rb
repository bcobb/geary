require_relative 'sugar'

module Geary
  module Packet
    extend Sugar

    request :SUBMIT_JOB, :number => 7, :as => 'SubmitJob',
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_BG, :number => 18, :as => 'SubmitJobBg',
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_HIGH, :number => 21, :as => 'SubmitJobHigh',
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_HIGH_BG, :number => 32, :as => 'SubmitJobHighBg',
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_LOW, :number => 33, :as => 'SubmitJobLow',
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_LOW_BG, :number => 33, :as => 'SubmitJobLowBg',
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_SCHED, :number => 35, :as => 'SubmitJobSched',
      :arguments => [:function_name, :unique_id, :minute, :hour,
                     :day_of_month, :month, :day_of_week, :data]

    request :SUBMIT_JOB_EPOCH, :number => 36, :as => 'SubmitJobEpoch',
      :arguments => [:function_name, :unique_id, :epoch_time, :data]

    response :JOB_CREATED, :number => 8, :as => 'JobCreated',
      :arguments => [:job_handle]

    request :GET_STATUS, :number => 15, :as => 'GetStatus',
      :arguments => [:job_handle]

    response :STATUS_RES, :number => 20, :as => 'StatusResponse',
      :arguments => [:job_handle, :known, :running,
                     :percent_complete_numerator,
                     :percent_complete_denominator]

    request :ECHO_REQ, :number => 16, :as => 'EchoRequest',
      :arguments => [:data]

    response :ECHO_RES, :number => 17, :as => 'EchoResponse',
      :arguments => [:data]

    request :OPTION_REQ, :number => 26, :as => 'OptionRequest',
      :arguments => [:option_name]

    response :OPTION_RES, :number => 27, :as => 'OptionResponse',
      :arguments => [:option_name]

    response :ERROR, :number => 19, :as => 'Error',
      :arguments => [:error_code, :error_text]

    customize 'StatusResponse' do

      def percent_complete
        if percent_complete_numerator.nil? || percent_complete_denominator.nil?
          0.0
        else
          percent_complete_numerator.to_f / percent_complete_denominator.to_f
        end
      end

      def complete?
        percent_complete == 1.0
      end

      def known?
        known.to_i == 1
      end

      def unknown?
        not known?
      end

      def running?
        running.to_i == 1
      end

      def stopped?
        not running?
      end

    end

  end
end
