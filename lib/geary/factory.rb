require 'virtus'
require 'socket'

require_relative 'client'
require_relative 'uuid_generator'
require_relative 'packet_stream'
require_relative 'packet_type_repository'
require_relative 'packet/all'

module Geary
  class Factory
    include Virtus::ValueObject

    attribute :host, String, :default => "localhost"
    attribute :port, Integer, :default => 4730

    def client
      socket = ::TCPSocket.new(host, port)

      uuid_generator = UUIDGenerator.new
      packet_type_repository = standard_packet_type_repository
      packet_stream = PacketStream.new(
        :connection => socket,
        :packet_type_repository => packet_type_repository
      )

      Client.new(
        :packet_stream => packet_stream,
        :unique_id_generator => uuid_generator
      )
    end

    def standard_packet_type_repository
      gearman_packet_types = Packet.constants.
        map { |c| Packet.const_get(c) }.
        select { |t| t.respond_to?(:packet_name) }

      PacketTypeRepository.seeded_with(gearman_packet_types)
    end

  end
end

__END__
#   Name                Magic  Type
1   CAN_DO              REQ    Worker
2   CANT_DO             REQ    Worker
3   RESET_ABILITIES     REQ    Worker
4   PRE_SLEEP           REQ    Worker
5   (unused)            -      -
6   NOOP                RES    Worker
9   GRAB_JOB            REQ    Worker
10  NO_JOB              RES    Worker
11  JOB_ASSIGN          RES    Worker
12  WORK_STATUS         REQ    Worker
                        RES    Client
13  WORK_COMPLETE       REQ    Worker
                        RES    Client
14  WORK_FAIL           REQ    Worker
                        RES    Client
20  STATUS_RES          RES    Client
22  SET_CLIENT_ID       REQ    Worker
23  CAN_DO_TIMEOUT      REQ    Worker
24  ALL_YOURS           REQ    Worker
25  WORK_EXCEPTION      REQ    Worker
                        RES    Client
26  OPTION_REQ          REQ    Client/Worker
27  OPTION_RES          RES    Client/Worker
28  WORK_DATA           REQ    Worker
                        RES    Client
29  WORK_WARNING        REQ    Worker
                        RES    Client
30  GRAB_JOB_UNIQ       REQ    Worker
31  JOB_ASSIGN_UNIQ     RES    Worker
35  SUBMIT_JOB_SCHED    REQ    Client
36  SUBMIT_JOB_EPOCH    REQ    Client
