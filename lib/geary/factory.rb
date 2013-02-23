require 'virtus'
require 'socket'

require_relative 'client'
require_relative 'worker_client'
require_relative 'uuid_generator'
require_relative 'packet_stream'
require_relative 'packet_type_repository'
require_relative 'packet/all'

module Geary
  class Factory
    include Virtus::ValueObject

    attribute :host, String, :default => "localhost"
    attribute :port, Integer, :default => 4730

    def client(options = {})
      socket = ::TCPSocket.new(host, port)

      unique_id_generator = options.fetch(:unique_id_generator) do
        UUIDGenerator.new
      end

      packet_type_repository = standard_packet_type_repository
      packet_stream = PacketStream.new(
        :connection => socket,
        :packet_type_repository => packet_type_repository
      )

      Client.new(
        :packet_stream => packet_stream,
        :unique_id_generator => unique_id_generator
      )
    end

    def worker_client
      socket = ::TCPSocket.new(host, port)

      packet_type_repository = standard_packet_type_repository
      packet_stream = PacketStream.new(
        :connection => socket,
        :packet_type_repository => packet_type_repository
      )

      WorkerClient.new(:packet_stream => packet_stream)
    end

    def standard_packet_type_repository
      gearman_packet_types = Packet.constants.
        map { |c| Packet.const_get(c) }.
        select { |t| t.respond_to?(:packet_name) }.
        reduce(PacketTypeRepository.new) do |repository, packet_type|
          [packet_type.protocol_number, packet_type.packet_name].each do |key|
            repository.store(packet_type.magic, key, packet_type)
          end

          repository
        end
    end

  end
end

__END__
#   Name                Magic  Type
12  WORK_STATUS         REQ    Worker
                        RES    Client
13  WORK_COMPLETE       REQ    Worker
                        RES    Client
14  WORK_FAIL           REQ    Worker
                        RES    Client
22  SET_CLIENT_ID       REQ    Worker
23  CAN_DO_TIMEOUT      REQ    Worker
24  ALL_YOURS           REQ    Worker
25  WORK_EXCEPTION      REQ    Worker
                        RES    Client
28  WORK_DATA           REQ    Worker
                        RES    Client
29  WORK_WARNING        REQ    Worker
                        RES    Client
