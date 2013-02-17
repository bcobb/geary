require 'geary'
require 'tempfile'

module Geary

  describe 'the packet reader' do

    let(:socket) { Tempfile.open('socket', 'spec/tmp') }

    subject(:reader) do
      translator = PacketTranslator.new
      reader = PacketReader.new(
	:source => socket,
	:translator => translator
      )
    end

    after { socket.close }

    it 'can read ECHO_RES packets' do
      body = 'test'
      header = ["\0RES", 17, body.size].pack('a4NN')

      socket.write(header + body)
      socket.rewind

      packet = reader.read

      expect(packet).to be_a(Packet::Echo)
      expect(packet.data).to eql(body)
    end

    it 'can read packet headers' do
      header = ["\0RES", 17, 4].pack('a4NN')

      socket.write(header)
      socket.rewind

      magic, type, arguments_length = reader.read_packet_header

      expect(magic).to eql("\0RES")
      expect(type).to eql(17)
      expect(arguments_length).to eql(4)
    end

    it 'can read packet arguments, given their length' do
      arguments = ['test', 'argument', 'here'].join("\0")

      socket.write(arguments)
      socket.rewind

      first, second, third = reader.read_packet_arguments(arguments.size)

      expect(first).to eql('test')
      expect(second).to eql('argument')
      expect(third).to eql('here')
    end

  end

end
