require "ast"

class Compiler
  def initialize
    @bytecode = []
  end
  
  def compile(node)
    compile_node(node)
    @bytecode << RETURN
  end
  
  private
    def compile_node(node)
      unless node.is_a?(Node)
        @bytecode << PUSH
        @bytecode << node
        return
      end
    
      case node.type
      when :PRINT
        compile_node(node.args[0])
        @bytecode << PRINT
      when :ADD
        compile_args(node)
        @bytecode << ADD
      end
    end
  
    def compile_args(node)
      node.args.each { |arg| compile_node(arg) }
    end
end
