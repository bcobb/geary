module WithoutLogging

  unless defined? QUIET_LOGGER
    QUIET_LOGGER = ::Logger.new(STDERR).tap { |l| l.level = ::Logger::FATAL }
  end

  def without_logging
    old_logger = Celluloid.logger

    begin
      Celluloid.logger = QUIET_LOGGER
      yield
    ensure
      Celluloid.logger = old_logger
    end
  end

end
