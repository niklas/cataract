attr = DS.attr

Cataract.Torrent = DS.Model.extend
  title: attr 'string'
  transfer: DS.belongsTo('transfer')
  info_hash: attr 'string'
  status: attr 'string'
  filename: attr 'string'
  url: attr 'string'
  payloadExists: attr 'boolean'
  isRunning: (-> @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')

  filedata: attr 'string' # TODO put into payload

  payload: DS.belongsTo('payload')
  payloadPresent: Ember.computed ->
    @get('payloadExists') and @get('payload.isLoaded') and !@get('payload.isDeleted')
  .property('payload.isLoaded', 'payload.isDeleted')
  clearPayload: ->
    if payload = @get('payload')
      payload.destroyRecord().then =>
        @set('payloadExists', false)

  contentDirectory: DS.belongsTo('directory')

  fetchAutomatically: attr 'boolean'
  startAutomatically: attr 'boolean'

Cataract.Torrent.reopenClass
  url: 'torrent'
  refreshFromHashes: (hash) ->
    for field in hash
      @get('store').find('torrent', field.id).then (record)->
        record.setProperties field if record?
    true
