require 'geary'
require 'debugger'

module Geary

  describe 'issuing an echo request' do

    specify 'from a client' do
      socket = ::TCPSocket.new('localhost', 4730)

      metal = Metal.new
      metal.echo_req('data', socket)
      response = metal.echo_res(socket)

      socket.close

      expect(response).to eql('data')
    end

  end

end
