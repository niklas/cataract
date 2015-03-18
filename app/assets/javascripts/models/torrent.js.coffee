attr = DS.attr

Cataract.Torrent = DS.Model.extend
  title: attr 'string'
  transfer: DS.belongsTo('transfer', async: true)
  info_hash: attr 'string'
  status: attr 'string'
  filename: attr 'string'
  url: attr 'string'
  payloadExists: attr 'boolean'
  payloadKiloBytes: attr 'number'
  isRunning: (-> @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')
  createdAt: attr 'date'
  updatedAt: attr 'date'

  filedata: attr 'string'

  payload: DS.belongsTo('payload', async: true)
  payloadPresent:
    Ember.computed ->
      @get('payloadExists') and @get('payload.isLoaded') and !@get('payload.isDeleted') and @get('payload.size') > 0
    .property('payload.isLoaded', 'payload.isDeleted', 'payloadExists', 'payload.size')
  clearPayload: ->
    if payload = @get('payload')
      torrent = this
      payload.destroyRecord().then ->
        torrent.set('payloadExists', false)
  payloadHumanSize:
    Ember.computed ->
      fileSize @get('payloadKiloBytes'), short: true
    .property('payloadKiloBytes')

  contentDirectory: DS.belongsTo('directory')
  contentPolyDirectory: PolyDiskDirectory.attr('contentDirectory')

  fetchAutomatically: attr 'boolean'
  startAutomatically: attr 'boolean'

Cataract.Torrent.reopenClass
  url: 'torrent'
  refreshFromHashes: (hash) ->
    for field in hash
      @get('store').find('torrent', field.id).then (record)->
        record.setProperties field if record?
    true
