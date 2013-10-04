# Emu = {} # FIXME legacy
# 
# Emu.IdentitySerializer =
#   serialize: (value) ->
#     if Ember.isEmpty(value)
#       null
#     else
#       value
# 
#   deserialize: (value) ->
#     if Ember.isEmpty(value)
#       null
#     else
#       value
# Emu.AttributeSerializers['number'] = Emu.IdentitySerializer
# Emu.AttributeSerializers['staticArray'] = Emu.IdentitySerializer
# 
# Emu.RailsSerializer = Emu.UnderscoreSerializer.extend
#   serializeModel: (model) ->
#     serialized = @_super(model)
#     delete serialized[model.primaryKey()]
#     wrapped = {}
#     wrapped[ model.constructor.url ] = serialized
#     wrapped
