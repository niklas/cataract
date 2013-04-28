Emu.IdentitySerializer =
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
Emu.AttributeSerializers['number'] = Emu.IdentitySerializer
Emu.AttributeSerializers['staticArray'] = Emu.IdentitySerializer

Emu.RailsSerializer = Emu.UnderscoreSerializer.extend
  serializeModel: (model) ->
    wrapped = {}
    wrapped[ model.constructor.url ] = @_super(model)
    wrapped
