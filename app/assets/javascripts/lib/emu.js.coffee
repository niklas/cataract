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
    serialized = @_super(model)
    delete serialized[model.primaryKey()]
    wrapped = {}
    wrapped[ model.constructor.url ] = serialized
    wrapped

Emu.belongsTo = (type, options) ->
  meta =
    type: -> Ember.get(type) || type
    options: options
    key: -> options.key

  Ember.computed (key, value) ->
    if arguments.length is 1 # getter
      if cid = @get(meta.key())
        meta.type().find(cid)
      else
        null
    else #setter
      if value?
        @set meta.key(), value.get('id')
      value
  .property(meta.key())

Emu.Model.reopen
  deleteRecord: ->
    @get("store").deleteRecord(this)
