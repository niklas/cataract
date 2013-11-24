Cataract.IdentityTransform = DS.Transform.extend
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

Cataract.StaticArrayTransform = Cataract.IdentityTransform.extend()

# Emu.RailsSerializer = Emu.UnderscoreSerializer.extend
#   serializeModel: (model) ->
#     serialized = @_super(model)
#     delete serialized[model.primaryKey()]
#     wrapped = {}
#     wrapped[ model.constructor.url ] = serialized
#     wrapped
