class Node
  attr_accessor :type, :args
  
  def initialize(type, args=[])
    @type = type
    @args = args
  end
  
  def inspect
    [@type, *@args].inspect
  end
end