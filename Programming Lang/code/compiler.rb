require "rubygems"
require "parser"
require "nodes"

require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'
require 'llvm/transforms/ipo'

LLVM.init_x86

# Compiler is used in a similar way as the runtime. But, instead of executing code, it
# will generate LLVM byte-code for later execution.
class Compiler
  
  # Initialize LLVM types
  PCHAR = LLVM::Type.pointer(LLVM::Int8) # equivalent to *char in C
  INT   = LLVM::Int # equivalent to int in C
  
  attr_reader :locals
  
  def initialize(mod=nil, function=nil)
    # Create the LLVM module in which to store the code
    @module = mod || LLVM::Module.create("awesome")
    
    # To track local names during compilation
    @locals = {}
    
    # Function in which the code will be put
    @function = function ||
                # By default we create a main function as it's the standard entry point
                @module.functions.named("main") ||
                @module.functions.add("main", [INT, LLVM::Type.pointer(PCHAR)], INT)
    
    # Create an LLVM byte-code builder
    @builder = LLVM::Builder.create
    @builder.position_at_end(@function.basic_blocks.append)
    
    @engine = LLVM::ExecutionEngine.create_jit_compiler(@module)
  end
  
  # Initial header to initialize the module.
  def preamble
    define_external_functions
  end
  
  def finish
    @builder.ret(LLVM::Int(0))
  end
  
  # Create a new string.
  def new_string(value)
    @builder.global_string_pointer(value)
  end

  # Create a new number.
  def new_number(value)
    LLVM::Int(value)
  end
  
  # Call a function.
  def call(func, args=[])
    f = @module.functions.named(func)
    @builder.call(f, *args)
  end
  
  # Assign a local variable
  def assign(name, value)
    # Allocate the memory and returns a pointer to it
    ptr = @builder.alloca(value.type)
    # Store the value insite the pointer
    @builder.store(value, ptr)
    # Keep track of the pointer so the compiler can find it back name later.
    @locals[name] = ptr
  end
  
  # Load the value of a local variable.
  def load(name)
    @builder.load(@locals[name])
  end
  
  # Defines a function.
  def function(name)
    func = @module.functions.add(name, [], INT)
    generator = Compiler.new(@module, func)
    yield generator
    generator.finish
  end
  
  # Optimize the generated LLVM byte-code.
  def optimize
    @module.verify!
    pass_manager = LLVM::PassManager.new(@engine)
    pass_manager.simplifycfg! # Simplify the CFG
    pass_manager.mem2reg!     # Promote Memory to Register
    pass_manager.gdce!        # Dead Global Elimination
  end
  
  # JIT compile and run the LLVM byte-code.
  def run
    @engine.run_function(@function, 0, 0)
  end
  
  def dump
    @module.dump
  end
  
  private
    def define_external_functions
      fun = @module.functions.add("printf", [LLVM::Type.pointer(PCHAR)], INT, { :varargs => true })
      fun.linkage = :external

      fun = @module.functions.add("puts", [PCHAR], INT)
      fun.linkage = :external

      fun = @module.functions.add("read", [INT, PCHAR, INT], INT)
      fun.linkage = :external

      fun = @module.functions.add("exit", [INT], INT)
      fun.linkage = :external
    end
end

# Reopen class supported by the compiler to implement how each node is compiled
# (compile method).

class Nodes
  def compile(compiler)
    nodes.map { |node| node.compile(compiler) }.last
  end
end

class NumberNode
  def compile(compiler)
    compiler.new_number(value)
  end
end

class StringNode
  def compile(compiler)
    compiler.new_string(value)
  end
end

class CallNode
  def compile(compiler)
    raise "Receiver not supported for compilation" if receiver
    
    # Local variable access
    if receiver.nil? && arguments.empty? && compiler.locals[method]
      compiler.load(method)
    
    # Method call
    else
      compiled_arguments = arguments.map { |arg| arg.compile(compiler) }
      compiler.call(method, compiled_arguments)
    end
  end
end

class SetLocalNode
  def compile(compiler)
    compiler.assign(name, value.compile(compiler))
  end
end

class DefNode
  def compile(compiler)
    raise "Parameters not supported for compilation" if !params.empty?
    compiler.function(name) do |function|
      body.compile(function)
    end
  end
end
