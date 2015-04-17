attr = DS.attr
Cataract.Setting = DS.Model.extend

  # OPTIMIZE must simulate association because there is no reflecting assoc in Cataract.Directory ?
  incomingDirectory: DS.belongsTo('directory', async: true)
  disableSignup: attr 'boolean'
  bookmarkLink: attr 'string'

  # FIXME ember does not touch isDirty on belongsTo
  #       does not revert back automatically
  hasDirtyIncomingDirectory: false
  isKindofDirty: Ember.computed.or('isDirty', 'hasDirtyIncomingDirectory')
  incomingDirectoryChanged: ((value, attrname)->
    @set 'hasDirtyIncomingDirectory', true
  ).observes('incomingDirectory')

  save: ->
    @_super().then (me) me.set('hasDirtyIncomingDirectory', false)
