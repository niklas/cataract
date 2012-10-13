Cataract.Torrent = DS.Model.extend
  title: DS.attr 'string'
  transfer: DS.belongsTo 'Cataract.Transfer'
  info_hash: DS.attr 'string'
  status: DS.attr 'string'
  filename: DS.attr 'string'
  url: DS.attr 'string'
  isRunning: (-> @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')

  filedata: DS.attr 'string' # TODO put into payload
  payloadId: DS.attr 'number'
  payloadExists: (-> @get('payloadId')? ).property('payloadId')
  payload: DS.belongsTo 'Cataract.Payload'

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
