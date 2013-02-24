require_relative 'sugar'

module Geary
  module Packet
    extend Sugar

    request :SUBMIT_JOB, :number => 7,
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_BG, :number => 18,
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_HIGH, :number => 21,
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_HIGH_BG, :number => 32,
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_LOW, :number => 33,
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_LOW_BG, :number => 33,
      :arguments => [:function_name, :unique_id, :data]

    request :SUBMIT_JOB_SCHED, :number => 35,
      :arguments => [:function_name, :unique_id, :minute, :hour,
                     :day_of_month, :month, :day_of_week, :data]

    request :SUBMIT_JOB_EPOCH, :number => 36,
      :arguments => [:function_name, :unique_id, :epoch_time, :data]

    response :JOB_CREATED, :number => 8, :arguments => [:job_handle]

    request :GET_STATUS, :number => 15, :arguments => [:job_handle]

    response :STATUS_RES, :number => 20, :as => 'StatusResponse',
      :arguments => [:job_handle, :known, :running,
                     :percent_complete_numerator,
                     :percent_complete_denominator]

    request :CAN_DO, :number => 1, :arguments => [:function_name]
    request :CANT_DO, :number => 2, :arguments => [:function_name]
    request :RESET_ABILITIES, :number => 3

    request :GRAB_JOB, :number => 9
    request :GRAB_JOB_UNIQ, :number => 30

    response :NO_JOB, :number => 10

    response :JOB_ASSIGN, :number => 11,
      :arguments => [:job_handle, :function_name, :data]

    response :JOB_ASSIGN_UNIQ, :number => 31,
      :arguments => [:job_handle, :function_name, :unique_id, :data]

    request :PRE_SLEEP, :number => 4
    response :NOOP, :number => 6, :as => 'NoOp'

    request :WORK_STATUS, :number => 12, :as => 'WorkStatusRequest',
      :arguments => [:job_handle, :numerator, :denominator]

    response :WORK_STATUS, :number => 12, :as => 'WorkStatusResponse',
      :arguments => [:job_handle, :numerator, :denominator]

    request :WORK_COMPLETE, :number => 13, :as => 'WorkCompleteRequest',
      :arguments => [:job_handle, :data]

    response :WORK_COMPLETE, :number => 13, :as => 'WorkCompleteResponse',
      :arguments => [:job_handle, :data]

    request :WORK_FAIL, :number => 14, :as => 'WorkFailRequest',
      :arguments => [:job_handle]

    response :WORK_FAIL, :number => 14, :as => 'WorkFailResponse',
      :arguments => [:job_handle]

    request :WORK_EXCEPTION, :number => 25, :as => 'WorkExceptionRequest',
      :arguments => [:job_handle, :data]

    response :WORK_EXCEPTION, :number => 25, :as => 'WorkExceptionResponse',
      :arguments => [:job_handle, :data]

    request :ECHO_REQ, :number => 16, :as => 'EchoRequest',
      :arguments => [:data]

    response :ECHO_RES, :number => 17, :as => 'EchoResponse',
      :arguments => [:data]

    request :OPTION_REQ, :number => 26, :as => 'OptionRequest',
      :arguments => [:option_name]

    response :OPTION_RES, :number => 27, :as => 'OptionResponse',
      :arguments => [:option_name]

    response :ERROR, :number => 19, :arguments => [:error_code, :error_text]

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
