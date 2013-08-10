require 'timeout'

module WithTolerance

  Intolerant = Class.new(StandardError) unless defined? Intolerant

  def with_tolerance(&block)
    expectation_error = nil

    begin
      Timeout.timeout(1, Intolerant) do
        begin
          block.call
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expectation_error = e
          retry
        end
      end
    rescue Intolerant => i
      raise (expectation_error || i)
    end
  end

end
