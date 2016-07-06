module Mio
  # Bootstrap
  object = Object.new
  
  object["clone"] = proc { |receiver, context| receiver.clone }
  object["set_slot"] = proc do |receiver, context, name, value|
    receiver[name.call(context).value] = value.call(context)
  end
  object["print"] = proc do |receiver, context|
    puts receiver.value
    Lobby["nil"]
  end

  # Introducing the Lobby! Where all the fantastic objects live and also the root context
  # of evaluation.
  Lobby = object.clone

  Lobby["Lobby"]   = Lobby
  Lobby["Object"]  = object
  Lobby["nil"]     = object.clone(nil)
  Lobby["true"]    = object.clone(true)
  Lobby["false"]   = object.clone(false)
  Lobby["Number"]  = object.clone(0)
  Lobby["String"]  = object.clone("")
  Lobby["List"]    = object.clone([])
  Lobby["Message"] = object.clone
  Lobby["Method"]  = object.clone

  # The method we'll use to define methods.
  Lobby["method"] = proc { |receiver, context, message| Method.new(context, message) }
end
