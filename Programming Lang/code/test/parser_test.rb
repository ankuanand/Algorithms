require "test_helper"
require "parser"

class ParserTest < Test::Unit::TestCase
  def test_number
    assert_equal Nodes.new([NumberNode.new(1)]), Parser.new.parse("1")
  end
  
  def test_expression
    assert_equal Nodes.new([NumberNode.new(1), StringNode.new("hi")]), Parser.new.parse(%{1\n"hi"})
  end
  
  def test_call
    assert_equal Nodes.new([CallNode.new(NumberNode.new(1), "method", [])]), Parser.new.parse("1.method")
  end
  
  def test_call_with_arguments
    assert_equal Nodes.new([CallNode.new(nil, "method", [NumberNode.new(1), NumberNode.new(2)])]), Parser.new.parse("method(1, 2)")
  end
  
  def test_assign
    assert_equal Nodes.new([SetLocalNode.new("a", NumberNode.new(1))]), Parser.new.parse("a = 1")
    assert_equal Nodes.new([SetConstantNode.new("A", NumberNode.new(1))]), Parser.new.parse("A = 1")
  end
  
  def test_def
    code = <<-CODE
def method:
  true
CODE
    
    nodes = Nodes.new([
      DefNode.new("method", [],
        Nodes.new([TrueNode.new])
      )
    ])
    
    assert_equal nodes, Parser.new.parse(code)
  end
  
  def test_def_with_param
    code = <<-CODE
def method(a, b):
  true
CODE
    
    nodes = Nodes.new([
      DefNode.new("method", ["a", "b"],
        Nodes.new([TrueNode.new])
      )
    ])
    
    assert_equal nodes, Parser.new.parse(code)
  end
  
  def test_class
    code = <<-CODE
class Muffin:
  true
CODE
    
    nodes = Nodes.new([
      ClassNode.new("Muffin",
        Nodes.new([TrueNode.new])
      )
    ])
    
    assert_equal nodes, Parser.new.parse(code)
  end
  
  def test_arithmetic
    nodes = Nodes.new([
      CallNode.new(NumberNode.new(1), "+", [
        CallNode.new(NumberNode.new(2), "*", [NumberNode.new(3)])
      ])
    ])
    assert_equal nodes, Parser.new.parse("1 + 2 * 3")
    assert_equal nodes, Parser.new.parse("1 + (2 * 3)")
  end
  
  def test_binary_operator
    assert_equal Nodes.new([
      CallNode.new(
        CallNode.new(NumberNode.new(1), "+", [NumberNode.new(2)]),
        "||",
        [NumberNode.new(3)]
      )
    ]), Parser.new.parse("1 + 2 || 3")
  end
  
  ## Exercise: Add a grammar rule to handle the `!` unary operators
  # Remove the x in front of the method name to run.
  def xtest_unary_operator
    assert_equal Nodes.new([
      CallNode.new(NumberNode.new(2), "!", [])
    ]), Parser.new.parse("!2")
  end
  
  def test_if
    code = <<-CODE
if true:
  nil
CODE
    
    nodes = Nodes.new([
      IfNode.new(TrueNode.new,
        Nodes.new([NilNode.new])
      )
    ])
    
    assert_equal nodes, Parser.new.parse(code)
  end
end