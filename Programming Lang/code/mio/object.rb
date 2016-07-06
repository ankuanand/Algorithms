module Mio
  class Object
    attr_accessor :slots, :protos, :value
    
    def initialize(proto=nil, value=nil)
      @protos = [proto].compact
      @value = value
      @slots = {}
    end
    
    # Lookup a slot in the current object and protos.
    def [](name)
      return @slots[name] if @slots.key?(name)
      message = nil
      @protos.each { |proto| return message if message = proto[name] }
      raise Mio::Error, "Missing slot: #{name.inspect}"
    end
    
    # Set a slot
    def []=(name, message)
      @slots[name] = message
    end
    
    # The call method is used to eval an object.
    # By default objects eval to themselves.
    def call(*)
      self
    end
    
    def clone(val=nil)
      val ||= @value && @value.dup rescue TypeError
      Object.new(self, val)
    end
  end
end