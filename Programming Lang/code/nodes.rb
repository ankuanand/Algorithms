# Collection of nodes each one representing an expression.
class Nodes < Struct.new(:nodes)
  def <<(node)
    nodes << node
    self
  end
end

# Literals are static values that have a Ruby representation, eg.: a string, a number, 
# true, false, nil, etc.
class LiteralNode < Struct.new(:value); end
class NumberNode < LiteralNode; end
class StringNode < LiteralNode; end
class TrueNode < LiteralNode
  def initialize
    super(true)
  end
end
class FalseNode < LiteralNode
  def initialize
    super(false)
  end
end
class NilNode < LiteralNode
  def initialize
    super(nil)
  end
end

# Node of a method call or local variable access, can take any of these forms:
# 
#   method # this form can also be a local variable
#   method(argument1, argument2)
#   receiver.method
#   receiver.method(argument1, argument2)
#
class CallNode < Struct.new(:receiver, :method, :arguments); end

# Retrieving the value of a constant.
class GetConstantNode < Struct.new(:name); end

# Setting the value of a constant.
class SetConstantNode < Struct.new(:name, :value); end

# Setting the value of a local variable.
class SetLocalNode < Struct.new(:name, :value); end

# Method definition.
class DefNode < Struct.new(:name, :params, :body); end

# Class definition.
class ClassNode < Struct.new(:name, :body); end

# "if" control structure. Look at this node if you want to implement other control
# structures like while, for, loop, etc.
class IfNode  < Struct.new(:condition, :body); end