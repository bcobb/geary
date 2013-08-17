require 'support/fake_server'
require 'gearman/address'
require 'gearman/connection'

module Gearman

  describe Connection do
   
    let!(:address) { Gearman::Address.new(host: '127.0.0.1', port: 4730) }
    let!(:server) { FakeServer.new(address) }

    before do
      server.async.run
    end

    after do
      server.shutdown
    end

    it 'can write packets to a socket' do
      connection = Connection.new(address)
      connection.write(Gearman::Packet::WORK_COMPLETE.new(['*', '*']))

      expect(server.packets_read.last).
        to eql(Gearman::Packet::WORK_COMPLETE.new(['*', '*']))
    end

    it 'can read packets from a socket' do
      server.respond_with(Gearman::Packet::NO_JOB.new)

      connection = Connection.new(address)
      connection.write(Gearman::Packet::GRAB_JOB.new)

      expect(connection.next).to eql(Gearman::Packet::NO_JOB.new)
    end

    it 'can specify that it expects only certain types of packets' do
      server.respond_with(Gearman::Packet::JOB_ASSIGN.new([1] * 3))

      connection = Connection.new(address)
      connection.write(Gearman::Packet::GRAB_JOB.new)

      expect do
        Celluloid.logger = nil
        connection.next(Gearman::Packet::NO_JOB)
      end.to raise_error(Connection::UnexpectedPacketError)
    end

  end
end
