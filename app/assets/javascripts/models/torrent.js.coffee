Cataract.Torrent = DS.Model.extend
  title: DS.attr 'string'
  # must simulate belongsTo thx to https://github.com/emberjs/data/issues/380
  transfer: (-> Cataract.Transfer.find(@get('id'))).property()
  info_hash: DS.attr 'string'
  status: DS.attr 'string'
  filename: DS.attr 'string'
  url: DS.attr 'string'
  isRunning: (-> @get('transfer') and @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')

  filedata: DS.attr 'string' # TODO put into payload
  payloads: DS.hasMany 'Cataract.Payload' # HACK
  payload: (-> Cataract.Payload.find(@get('id'))).property()
  payloadExists: (-> @get('payload')? ).property('payloadId')

  contentDirectory: DS.belongsTo('Cataract.Directory', key: 'content_directory_id')

  fetchAutomatically: DS.attr 'boolean'
  startAutomatically: DS.attr 'boolean'

Cataract.Torrent.reopenClass
  url: 'torrent'
  refreshFromHashes: (hash) ->
    for attr in hash
      record = Cataract.store.find(Cataract.Torrent, attr.id)
      record.setProperties attr if record?
    true
