Emu.AttributeSerializers['number'] =
  serialize: (value) ->
    if Ember.isEmpty(value)
      null
    else
      value

  deserialize: (value) ->
    if Ember.isEmpty(value)
      null
    else
      value
