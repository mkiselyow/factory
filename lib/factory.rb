# frozen_string_literal: true

# Struct clone
class Factory
  def self.new(*class_attributes, &block)
    if class_attributes.first.is_a?(String)
      if class_attributes.first =~ /^[A-Z]\w+(([A-Z]\w+)?)+/
        class_name = class_attributes.shift
      else
        class_attributes.shift
      end
    end

    new_class = Class.new do
      # extend Forwardable

      attr_accessor *class_attributes

      define_method :initialize do |*args|
        raise(ArgumentError) if class_attributes.count < args.count
        args.each_with_index do |arg, index|
          key = "@#{class_attributes[index]}"
          instance_variable_set(key, arg)
        end
        @class_attributes = class_attributes
      end

      def ==(other)
        what_about_values = @class_attributes.inject(true) do |acc, attribute|
          acc && (public_send(attribute) == other.public_send(attribute))
        end
        what_about_values && self.class == other.class
      end

      def get_key(attribute)
        if attribute.is_a?(Integer) || attribute.is_a?(Float)
          raise IndexError unless @class_attributes[attribute]
          "@#{@class_attributes[attribute.to_i]}"
        else
          raise NameError unless public_send(attribute)
          "@#{attribute}"
        end
      end

      def [](attribute)
        key = get_key(attribute)
        instance_variable_get(key)
      end

      def []=(attribute, arg)
        key = get_key(attribute)
        instance_variable_set(key, arg)
      end

      def dig(*attributes)
        attributes.inject(self) do |obj, attribute|
          break unless obj
          begin
            obj[attribute]
          rescue NoMethodError => e
            p e
            nil
          end
        end
      end

      def each_pair
        members.each do |member|
          yield member, send(member)
        end
      end

      define_method :members do
        class_attributes
      end

      define_method :values do
        class_attributes.map { |attribute| send(attribute) }
      end

      # def_delegator :members, :count, :length

      def each(&block)
        values.each(&block)
      end

      def length
        members.length
      end

      def select(&block)
        values.select(&block)
      end

      def values_at(*selectors)
        selectors.map do |selector|
          values[selector] ? values[selector] : raise(IndexError)
        end
      end

      # alias_method :length, :size
      alias_method :size, :length
      alias_method :to_a, :values

      class_eval(&block) if block_given?
    end
    class_name ? const_set(class_name, new_class) : new_class
  end
end
