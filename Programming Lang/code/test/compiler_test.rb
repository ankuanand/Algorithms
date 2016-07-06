require "test_helper"

begin
require "compiler"

class CompilerTest < Test::Unit::TestCase
  def test_compile
    code = <<-CODE
def say_it:
  x = "This is compiled!"
  puts(x)
say_it
CODE

    # Parse the code
    node = Parser.new.parse(code)

    # Compile it
    compiler = Compiler.new
    compiler.preamble
    node.compile(compiler)
    compiler.finish

    # Uncomment to output LLVM byte-code
    # compiler.dump

    # Optimize the LLVM byte-code
    compiler.optimize

    # JIT compile & execute
    compiler.run
  end
end

rescue LoadError
  warn "Skipping compiler tests: gem install ruby-llvm to run"
end