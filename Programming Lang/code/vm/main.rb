require "lexer.rex"
require "parser.tab.rb"
require "compiler"
require "vm"

code = "print 1 + 2"
puts "Code:"
p code
puts

node = Parser.new.scan_str(code)
puts "Lexer + Parser => AST:"
p node
puts

bytecode = Compiler.new.compile(node)
puts "Compiler => Bytecode:"
p bytecode
puts

puts "VM#run"
VM.new.run(bytecode)
