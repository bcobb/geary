module Gearman
  module Packet
    module Sugar

      def self.type(name, options)
        if Gearman::Packet.const_defined?(name)
          return Gearman::Packet.const_get(name)
        end

        class_ = Class.new do
          extend Sugar

          takes *Array(options[:takes])
          number Integer(options[:number])

          def inspect
            info = argument_names.map do |argument_name|
              "#{argument_name}=#{public_send(argument_name)}"
            end

            if info.any?
              "#<#{self.class.name} #{info.join(' ')}>"
            else
              "#<#{self.class.name}>"
            end
          end

          def ==(other)
            quack = other.respond_to?(:arguments) && other.respond_to?(:number)

            if quack
              arguments == other.arguments && number == other.number
            else
              false
            end
          end
          alias :eql? :==

        end

        Gearman::Packet.const_set(name, class_)
      end

      def takes(*arguments)
        define_method(:initialize) do |attributes_or_arguments = []|
          __sugar_set = ->(argument, value) do
            ivar = "@#{argument}"

            instance_variable_set(ivar, value)
          end

          if attributes_or_arguments.is_a?(Hash)
            attributes = attributes_or_arguments
            arguments.each do |argument|
              begin
                value = attributes.fetch(argument.to_sym)
              rescue KeyError
                raise ArgumentError, "expected to be given :#{argument}"
              end

              __sugar_set.(argument, value)
            end
          elsif attributes_or_arguments.is_a?(Array)
            given = attributes_or_arguments

            if given.size != arguments.size
              raise ArgumentError,
                "expected to be given #{arguments.size} arguments"
            end

            arguments.zip(given).each do |argument, value|
              __sugar_set.(argument, value)
            end
          else
            raise ArgumentError,
              "expected either a Hash of attributes or an Array of arguments"
          end
        end

        attr_reader(*arguments)

        define_method(:argument_names) do
          self.class.const_get('ARGUMENTS')
        end

        define_method(:arguments) do
          argument_names.map { |argument_name| public_send(argument_name) }
        end

        self.const_set('ARGUMENTS', arguments)
      end

      def number(n)
        define_method(:number) do
          self.class.const_get('NUMBER')
        end

        self.const_set('NUMBER', n)
      end

    end
  end
end
