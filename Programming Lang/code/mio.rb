$:.unshift "."
require "mio/object"
require "mio/message"
require "mio/method"
require "mio/bootstrap"

module Mio
  class Error < RuntimeError
    attr_accessor :current_message
    
    def message
      super + " in message `#{@current_message.to_s}` at line #{@current_message.line}"
    end
  end

  def self.eval(code)
    # Parse
    message = Message.parse(code)
    # Eval
    message.call(Lobby)
  end
  
  def self.load(file)
    eval File.read(file)
  end
  
  load "mio/boolean.mio"
  load "mio/if.mio"
end
