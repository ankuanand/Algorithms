module Mio
  # Message is a chain of tokens produced when parsing.
  #   1 print.
  # is parsed to:
  #   Message.new("1",
  #               Message.new("print"))
  # You can then +call+ the top level Message to eval it.
  class Message < Object
    attr_accessor :next, :name, :args, :line, :cached_value
    
    def initialize(name, line)
      @name = name
      @args = []
      @line = line
      
      # Literals are static values, we can eval them right
      # away and cache the value.
      @cached_value = case @name
      when /^\d+/
        Lobby["Number"].clone(@name.to_i)
      when /^"(.*)"$/
        Lobby["String"].clone($1)
      end
      
      @terminator = [".", "\n"].include?(@name)
      
      super(Lobby["Message"])
    end
    
    # Call (eval) the message on the +receiver+.
    def call(receiver, context=receiver, *args)
      if @terminator
        # reset receiver to object at begining of the chain.
        # eg.:
        #   hello there. yo
        #  ^           ^__ "." resets back to the receiver here
        #  \________________________________________________/
        value = context
      elsif @cached_value
        # We already got the value
        value = @cached_value
      else
        # Lookup the slot on the receiver
        slot = receiver[name]
        
        # Eval the object in the slot
        value = slot.call(receiver, context, *@args)
      end
      
      # Pass to next message if some
      if @next
        @next.call(value, context)
      else
        value
      end
    rescue Mio::Error => e
      # Keep track of the message that caused the error to output
      # line number and such.
      e.current_message ||= self
      raise
    end
    
    def to_s(level=0)
      s = "  " * level
      s << "<Message @name=#{@name}"
      s << ", @args=" + @args.inspect unless @args.empty?
      s << ", @next=\n" + @next.to_s(level + 1) if @next
      s + ">"
    end
    
    # Parse a string into a chain of messages
    def self.parse(code)
      parse_all(code, 1).last
    end
    
    private
      def self.parse_all(code, line)
        code = code.strip
        i = 0
        message = nil
        messages = []
        
        # Marrrvelous parsing code!
        while i < code.size
          case code[i..-1]
          when /\A("[^"]*")/, # string
               /\A(\d+)/,     # number
               /\A(\.)+/,     # dot
               /\A(\n)+/,     # line break
               /\A(\w+)/      # name
            m = Message.new($1, line)
            if messages.empty?
              messages << m
            else
              message.next = m
            end
            line += $1.count("\n")
            message = m
            i += $1.size - 1
          when /\A(\(\s*)/ # arguments
            start = i + $1.size
            level = 1
            while level > 0 && i < code.size
              i += 1
              level += 1 if code[i] == ?\(
              level -= 1 if code[i] == ?\)
            end
            line += $1.count("\n")
            code_chunk = code[start..i-1]
            message.args = parse_all(code_chunk, line)
            line += code_chunk.count("\n")
          when /\A,(\s*)/
            line += $1.count("\n")
            messages.concat parse_all(code[i+1..-1], line)
            break
          when /\A(\s+)/, # ignore whitespace
               /\A(#.*$)/ # ignore comments
            line += $1.count("\n")
            i += $1.size - 1
          else
            raise "Unknown char #{code[i].inspect} at line #{line}"
          end
          i += 1
        end
        messages
      end
  end
end