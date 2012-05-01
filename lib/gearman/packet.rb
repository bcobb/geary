module Gearman
  class Packet

    HEADER_LENGTH = 12
    HEADER_PACKING = 'a4NN'
    NULL_BYTE = "\0"

    def self.load(socket)
      magic, type, rest = socket.read(HEADER_LENGTH).unpack(HEADER_PACKING)
      arguments = socket.read(rest).split(NULL_BYTE)

      new(magic, type, arguments)
    end

    def self.dump(packet)
      body = packet[:arguments].join(NULL_BYTE)
      header = [packet[:magic], packet[:type], body.length].pack(HEADER_PACKING)

      header + body
    end

    attr_reader :magic, :type, :arguments

    def initialize(magic, type, arguments)
      @magic = magic
      @type = type
      @arguments = arguments
    end

    def request?
      @magic == Gearman::Request::MAGIC
    end

    def [](attr)
      send attr
    end

    module Factory

      def type(mapping, *arguments)
        factories = mapping.map do |method, type|
          %{
            def #{method}(#{arguments.join(", ")})
              new(#{type}, #{arguments.join(", ")})
            end
          }
        end

        queries = mapping.map do |method, type|
          %{
            def #{method}?
              @packet.type.to_s == '#{type}' && @packet.request?
            end
          }
        end

        instance_eval methods.join
        class_eval queries.join
      end

    end

  end
end
