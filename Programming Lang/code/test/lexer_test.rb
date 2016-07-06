require "test_helper"
require "lexer"

class LexerTest < Test::Unit::TestCase
  def test_number
    assert_equal [[:NUMBER, 1]], Lexer.new.tokenize("1")
  end
  
  def test_string
    assert_equal [[:STRING, "hi"]], Lexer.new.tokenize('"hi"')
  end
    
  def test_identifier
    assert_equal [[:IDENTIFIER, "name"]], Lexer.new.tokenize('name')
  end
  
  def test_constant
    assert_equal [[:CONSTANT, "Name"]], Lexer.new.tokenize('Name')
  end
  
  def test_operator
    assert_equal [["+", "+"]], Lexer.new.tokenize('+')
    assert_equal [["||", "||"]], Lexer.new.tokenize('||')
  end
  
  def test_indent
    code = <<-CODE
if 1:
  print "..."
  if false:
    pass
  print "done!"
print "The End"
CODE
    tokens = [
      [:IF, "if"], [:NUMBER, 1],
      [:INDENT, 2],
        [:IDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
        [:IF, "if"], [:FALSE, "false"],
        [:INDENT, 4],
          [:IDENTIFIER, "pass"],
        [:DEDENT, 2], [:NEWLINE, "\n"],
        [:IDENTIFIER, "print"],
        [:STRING, "done!"],
     [:DEDENT, 0], [:NEWLINE, "\n"],
     [:IDENTIFIER, "print"], [:STRING, "The End"]
    ]
    assert_equal tokens, Lexer.new.tokenize(code)
  end
  
  ## Exercise: Modify the lexer to delimit blocks with <code>{ ... }</code> instead of indentation.
  def test_braket_lexer
    require "bracket_lexer"
    
    code = <<-CODE
if 1 {
  print "..."
  if false {
    pass
  }
  print "done!"
}
print "The End"
CODE

    tokens = [
      [:IF, "if"], [:NUMBER, 1],
      ["{", "{"], [:NEWLINE, "\n"],
        [:IDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
        [:IF, "if"], [:FALSE, "false"], ["{", "{"], [:NEWLINE, "\n"],
          [:IDENTIFIER, "pass"], [:NEWLINE, "\n"],
        ["}", "}"], [:NEWLINE, "\n"],
        [:IDENTIFIER, "print"], [:STRING, "done!"], [:NEWLINE, "\n"],
      ["}", "}"], [:NEWLINE, "\n"],
      [:IDENTIFIER, "print"], [:STRING, "The End"]
    ]
    assert_equal tokens, BracketLexer.new.tokenize(code)
  end
end