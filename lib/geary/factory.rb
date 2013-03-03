require 'virtus'
require 'socket'

require_relative 'client/binary_protocol'
require_relative 'worker/binary_protocol'
require_relative 'admin_client'
require_relative 'uuid_generator'
require_relative 'binary_protocol_stream'
require_relative 'text_protocol_stream'
require_relative 'packet_type_repository'
require_relative 'packet/all'

module Geary
  class Factory
    include Virtus::ValueObject

    attribute :host, String, :default => "localhost"
    attribute :port, Integer, :default => 4730
    attribute :packet_type_repository, PacketTypeRepository,
      :default => :standard_packet_type_repository

    def client(options = {})
      socket = open_socket(host, port)

      unique_id_generator = options.fetch(:unique_id_generator) do
        UUIDGenerator.new
      end

      connection = BinaryProtocolStream.new(
        :io => socket,
        :packet_type_repository => packet_type_repository
      )

      Client::BinaryProtocol.new(
        :connection => connection,
        :unique_id_generator => unique_id_generator
      )
    end

    def worker_client
      socket = open_socket(host, port)

      connection = BinaryProtocolStream.new(
        :io => socket,
        :packet_type_repository => packet_type_repository
      )

      Worker::BinaryProtocol.new(:connection => connection)
    end

    def admin_client
      socket = open_socket(host, port)

      connection = TextProtocolStream.new(:io => socket)

      AdminClient.new(:connection => connection)
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

    def open_socket(host, port)
      begin
        ::TCPSocket.new(host, port)
      rescue Errno::ECONNREFUSED
        abort "Could not connect to the gearman server at #{host}:#{port}"
      end
    end

  end
end
