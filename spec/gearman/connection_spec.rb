require 'gearman/connection'
require 'support/fake_server'
require 'support/without_logging'
require 'uri'

module Gearman

  describe Connection do
    include WithoutLogging
   
    let!(:address) { URI('gearman://127.0.0.1:4730') }
    let!(:server) { FakeServer.new(address) }

    before do
      server.async.run
      server.wait :accept
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
      without_logging do
        server.respond_with(Gearman::Packet::JOB_ASSIGN.new([1] * 3))

        connection = Connection.new(address)
        connection.write(Gearman::Packet::GRAB_JOB.new)

        expect do
          connection.next(Gearman::Packet::NO_JOB)
        end.to raise_error(Connection::UnexpectedPacketError)
      end
    end

    it 'will raise a ServerError if it reads an error packet' do
      without_logging do
        server.respond_with(Gearman::Packet::ERROR.new(["E", "T"]))

        connection = Connection.new(address)
        connection.write(Gearman::Packet::GRAB_JOB.new)

        expect do
          connection.next(Gearman::Packet::NO_JOB)
        end.to raise_error(Connection::ServerError)
      end
    end

  end
end
