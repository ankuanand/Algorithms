# Represents a method defined in the runtime.
class AwesomeMethod
  def initialize(params, body)
    @params = params
    @body = body
  end
  
  def call(receiver, arguments)
    # Create a context of evaluation in which the method will execute.
    context = Context.new(receiver)
    
    # Assign arguments to local variables
    @params.each_with_index do |param, index|
      context.locals[param] = arguments[index]
    end
    
    @body.eval(context)
  end
end
