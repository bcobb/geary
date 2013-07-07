require 'gearmand_control'

AfterConfiguration do
  gearmand = GearmandControl.new(4730)

  Timeout.timeout(1) do
    gearmand.start

    at_exit { gearmand.stop }
  end
end
