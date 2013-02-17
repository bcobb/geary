require 'geary'

module Geary

  describe 'a client' do

    it 'can issue echo request' do
      socket = ::TCPSocket.new('localhost', 4730)
      translator = PacketTranslator.new
      reader = PacketReader.new(:source => socket, :translator => translator)

      echo = Echo.new(reader)
      expect(echo.call('test!').data).to eql('test!')

      socket.close
    end

  end

end
