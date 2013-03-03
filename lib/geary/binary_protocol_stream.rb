require 'forwardable'
require_relative 'packet/magic'

module Geary
  class BinaryProtocolStream
    extend Forwardable

    def_delegators :io, :close, :closed?

    FORMAT = 'a4NN' unless defined? FORMAT

    attr_reader :io, :packet_type_repository

    def initialize(options = {})
      @io = options.fetch(:io)
      @packet_type_repository = options.fetch(:packet_type_repository)
    end

    def request_with_response(type, *arguments)
      request(type, *arguments)

      read_response
    end

    def request(type, *arguments)
      packet = new_packet(Packet::Magic::REQUEST, type, :arguments => arguments)

      body = packet.arguments.join("\0")
      header = [packet.magic, packet.protocol_number, body.size].pack(FORMAT)

      write(header + body)
    end

    def read_response
      magic, type, arguments_length = read_packet_header

      if arguments_length > 0
        arguments = read_packet_arguments(arguments_length)
      else
        arguments = []
      end

      new_packet(magic, type, :arguments => arguments)
    end

    def read_packet_arguments(length)
      read(length).split("\0")
    end

    def read_packet_header
      read(12).unpack(FORMAT)
    end

    def new_packet(magic, type, *args)
      packet_type_repository.find(magic, type).new(*args)
    end

    def read(size)
      IO::select([io])
      io.read(size)
    end

    def write(stuff)
      IO::select([], [io])
      io.write(stuff)
    end

  end
end
