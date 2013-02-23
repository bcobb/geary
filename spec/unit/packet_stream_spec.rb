require 'tempfile'
require 'geary/packet_stream'
require 'geary/packet/all'

module Geary

  describe PacketStream do

    let(:connection) { Tempfile.new('connection', 'spec/tmp') }
    let(:repository) { double('PacketTypeRepository') }

    subject(:stream) do
      PacketStream.new(
        :connection => connection,
        :packet_type_repository => repository
      )
    end

    it 'writes requests to the connection' do
      repository.stub(:find) { Packet::EchoRequest }

      stream.write_request(:_, 'data')

      connection.rewind

      headers = connection.read(12).unpack(PacketStream::FORMAT)
      expect(headers).to eql(["\0REQ", 16, 4])

      body = connection.read(4)
      expect(body).to eql('data')
    end

    it 'reads responses from the connection' do
      header = ["\0RES", 17, 4].pack(PacketStream::FORMAT)
      body = 'data'

      connection.write(header + body)
      connection.rewind

      repository.stub(:find) { Packet::EchoResponse }

      expect(stream.read.data).to eql('data')
    end

    it 'reads responses with no arguments' do
      header = ["\0RES", 10, 0].pack(PacketStream::FORMAT)

      connection.write(header)
      connection.rewind

      repository.stub(:find) { Packet::NoJob }

      expect(stream.read.arguments).to be_empty
    end

  end

end
