# The evaluation context.
class Context
  attr_reader :locals, :current_self, :current_class
  
  # We store constants as class variable (class variables start with @@ and instance
  # variables start with @ in Ruby) since they are globally accessible. If you want to
  # implement namespacing of constants, you could store it in the instance of this 
  # class.
  @@constants = {}
  
  def initialize(current_self, current_class=current_self.runtime_class)
    @locals = {}
    @current_self = current_self
    @current_class = current_class
  end
  
  # Shortcuts to access constants, Runtime[...] instead of Runtime.constants[...]
  def [](name)
    @@constants[name]
  end
  def []=(name, value)
    @@constants[name] = value
  end
end
