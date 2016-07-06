# Bytecode
PUSH   = 0
ADD    = 1
PRINT  = 2
RETURN = 3

class VM
  def run(bytecode)
    # Stack to pass value between instructions.
    stack = []
    # Instruction Pointer, index of current instruction being executed in bytecode.
    ip = 0
    
    while true
      case bytecode[ip]
      when PUSH
        stack.unshift bytecode[ip+=1]
      when ADD
        stack.unshift stack.pop + stack.pop
      when PRINT
        puts stack.pop
      when RETURN
        return
      end
      
      # Continue to next intruction
      ip += 1
    end
  end
end

VM.new.run [
  # Here is the bytecode of our program, the equivalent of: print 1 + 2.
  # Opcode, Operand     # Status of the stack after execution of the instruction.
  PUSH,     1,          # stack = [1]
  PUSH,     2,          # stack = [2, 1]
  ADD,                  # stack = [3]
  PRINT,                # stack = []
  RETURN
]