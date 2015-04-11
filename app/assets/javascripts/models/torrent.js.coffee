attr = DS.attr

Cataract.Torrent = DS.Model.extend
  title: attr 'string'
  transfer: DS.belongsTo('transfer', async: true)
  info_hash: attr 'string'
  status: attr 'string'
  filename: attr 'string'
  url: attr 'string'
  payloadExists: attr 'boolean'
  payloadBytes: attr 'number'
  isRunning: (-> @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')
  createdAt: attr 'date'
  updatedAt: attr 'date'

  filedata: attr 'string'

  payload: DS.belongsTo('payload', async: true)

  clearPayload: ->
    torrent = this
    @get('payload').then (payload)->
      payload.deleteRecord()
      payload.save().then ->
        torrent.set('payloadExists', false)

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
