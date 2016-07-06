# Represents an Awesome object instance in the Ruby world.
class AwesomeObject
  attr_accessor :runtime_class, :ruby_value

  # Each object have a class (named runtime_class to prevent errors with Ruby's class
  # method). Optionaly an object can hold a Ruby value (eg.: numbers and strings).
  def initialize(runtime_class, ruby_value=self)
    @runtime_class = runtime_class
    @ruby_value = ruby_value
  end

  # Call a method on the object.
  def call(method, arguments=[])
    # Like a typical Class-based runtime model, we store methods in the class of the
    # object.
    @runtime_class.lookup(method).call(self, arguments)
  end
end