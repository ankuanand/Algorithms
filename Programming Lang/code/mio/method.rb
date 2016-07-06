module Mio
  class Method < Object
    def initialize(context, message)
      @definition_context = context
      @message = message
      super(Lobby["Method"])
    end

    def call(receiver, calling_context, *args)
      # Woo... lots of contexts here... lets clear that up:
      #   @definition_context: where the method was defined
      #       calling_context: where the method was called
      #        method_context: where the method body (message) is executing
      method_context = @definition_context.clone
      method_context["self"] = receiver
      method_context["arguments"] = Lobby["List"].clone(args)
      # Note: no argument is evaluated here. Our little language only has lazy argument
      # evaluation. If you pass args to a method, you have to eval them explicitly,
      # using the following method.
      method_context["eval_arg"] = proc do |receiver, context, at|
        (args[at.call(context).value] || Lobby["nil"]).call(calling_context)
      end
      @message.call(method_context)
    end
  end
end