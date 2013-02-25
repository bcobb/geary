require 'forwardable'
require_relative 'magic'

module Geary
  class GearmanPacketStream
    extend Forwardable

    def_delegator :connection, :close

    FORMAT = 'a4NN' unless defined? FORMAT

    attr_reader :connection, :packet_type_repository

    def initialize(options = {})
      @connection = options.fetch(:connection)
      @packet_type_repository = options.fetch(:packet_type_repository)
    end

    def request(type, *arguments)
      write_request(type, *arguments)

      read
    end

    def write_request(type, *arguments)
      write(Magic::REQUEST, type, *arguments)
    end

    def read
      magic, type, arguments_length = read_packet_header

      if arguments_length > 0
        arguments = read_packet_arguments(arguments_length)
      else
        arguments = []
      end

      new_packet(magic, type, :arguments => arguments)
    end

    def write(magic, type, *arguments)
      packet = new_packet(magic, type, :arguments => arguments)

      body = packet.arguments.join("\0")
      header = [packet.magic, packet.protocol_number, body.size].pack(FORMAT)

      connection.write(header + body)
    end

    def read_packet_arguments(length)
      connection.read(length).split("\0")
    end

    def read_packet_header
      connection.read(12).unpack(FORMAT)
    end

    def new_packet(magic, type, *args)
      packet_type_repository.find(magic, type).new(*args)
    end

  end
end
