class Factory
  attr_accessor :class_name, :class_attributes
  def initialize (class_name, *class_attributes)
    @class_name = class_name
    @class_attributes = class_attributes
  end

  def self.invoke_class(class_name, *class_attributes)
    @class_name       = class_name
    @class_attributes = class_attributes
    some_class = Object::Factory.const_set(@class_name, Class.new do
        array_of_attributes_symbols = class_attributes.map {|attr| attr.to_sym}
        array_of_attributes_symbols.each do |attr_sym|
          attr_accessor attr_sym
        end
        def initialize(attributes)
          attributes.each do |key, value|
            instance_variable_set("@#{key}", value) unless value.nil?
          end
        end
      end)
  end
end

@my_class_users = Factory.invoke_class("User", "name", "surname")
@my_class_users_instance = Factory::User.new(:name => "the some name", :surname => "some surname")
p @my_class_users
p @my_class_users_instance