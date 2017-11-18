class Factory

  def self.new(*class_attributes, &block)
    if class_attributes.first.is_a?(String)
      if class_attributes.first.match(/^[A-Z]\w+(([A-Z]\w+)?)+/)
        class_name = class_attributes.shift
      else
        class_attributes.shift
      end
    end

    new_class = Class.new do

      attr_accessor *class_attributes

      define_method :initialize do |*args|
        raise(ArgumentError) if class_attributes.count < args.count
        args.each_with_index do |arg, index|
          instance_variable_set("@#{class_attributes[index]}", arg) unless arg.nil?
        end
        @class_attributes = class_attributes
      end

      def ==(other)
        if self.class == other.class
          @class_attributes.each do |attribute|
            result = self.public_send(attribute) == other.public_send(attribute) if other.public_send(attribute)
            return false if result == false #inject
          end
        end
      end

      def [](attribute)
        if attribute.is_a?(Integer)
          key = "@#{@class_attributes[attribute]}"
        else
          key = "@#{attribute}"
        end
        instance_variable_get(key)
      end

      def []=(attribute, arg)
        if attribute.is_a?(Integer)
          key = "@#{@class_attributes[attribute]}"
        else
          key = "@#{attribute}"
        end
        instance_variable_set("@#{attribute}", arg)
      end

      def dig(*attributes)
        result = attributes.map {|attribute| self.methods.include?(attribute)}
        nil if result.any? { |any| any == false }
      end

      def each_pair
        members.each do |member|
          yield member, send(member)
        end
      end

      define_method :members do
        class_attributes
      end


      class_eval(&block) if block_given?
    end
    class_name ? const_set(class_name, new_class) : new_class
  end
end

# @my_class_users = Factory.invoke_class("User", "name", "surname")
# @my_class_users_instance = Factory::User.new(:name => "the some name", :surname => "some surname")
# p @my_class_users
# p @my_class_users_instance

# Factory = Struct

# p Factory.new('Customer', :name, :address)
# p Factory.new(:name, :address)

# customer = Factory::Customer.new('Dave', '123 Main')

# Customer = Factory.new(:name, :address) do
#   def greeting
#     "Hello #{name}!"
#   end
# end