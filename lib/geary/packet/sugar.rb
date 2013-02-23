require_relative 'standard'
require_relative '../magic'

module Geary
  module Packet
    module Sugar

      def response(packet_name, options = {})
        options.update(:magic => Magic::RESPONSE)

        build_packet_class(packet_name, options)
      end

      def request(packet_name, options = {})
        options.update(:magic => Magic::REQUEST)

        build_packet_class(packet_name, options)
      end

      def customize(class_name, &block)
        class_ = Packet.const_get(class_name)
        class_.class_eval(&block)
      end

      def build_packet_class(packet_name, options)
        magic = options.fetch(:magic)
        prototcol_number = options.fetch(:number)
        class_name = options.fetch(:as)
        argument_names = Array(options.fetch(:arguments, nil))

        argument_methods = argument_names.map.with_index do |name, index|
          %{
            def #{name}
              arguments[#{index}]
            end
          }
        end

        class_eval %{
          class #{class_name} < Standard

            def self.packet_name
              #{packet_name.inspect}
            end

            def self.magic
              #{magic.inspect}
            end

            def self.protocol_number
              #{prototcol_number}
            end

            def magic
              self.class.magic
            end

            def protocol_number
              self.class.protocol_number
            end

            #{argument_methods.join}

          end
        }
      end

    end
  end
end