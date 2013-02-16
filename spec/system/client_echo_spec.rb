require 'geary'

module Geary

  describe 'issuing an echo request' do

    specify 'from a client' do
      echoed_data = nil
      socket = ::TCPSocket.new('localhost', 4730)

      echo = Echo.new(socket)
      echo.call('data') do |response|
        echoed_data = response
      end

      socket.close

      expect(echoed_data).to eql('data')
    end

  end

end
