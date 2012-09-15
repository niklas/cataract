Cataract.Torrent = DS.Model.extend
  title: DS.attr 'string'
  transfer: DS.belongsTo 'Cataract.Transfer'
  info_hash: DS.attr 'string'
  status: DS.attr 'string'
  filename: DS.attr 'string'
  isRunning: (-> @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')

  transferURL: (-> "/torrents/#{@get('id')}/transfer" ).property('id')
  payloadURL: (-> "/torrents/#{@get('id')}/payload" ).property('id')

  payloadId: DS.attr 'number'
  payloadExists: (-> @get('payloadId')? ).property('payloadId')
  payload: DS.belongsTo 'Cataract.Payload'

Cataract.Torrent.reopenClass
  url: 'torrent'
  refreshFromHashes: (hash) ->
    for attr in hash
      record = Cataract.store.find(Cataract.Torrent, attr.id)
      record.setProperties attr if record?
    true

  refreshProgress: ->
    running = Cataract.store.filter Cataract.Torrent, (torrent) -> torrent.get('isRunning')
    $.getJSON "/progress?running=#{running.mapProperty('id').join(',')}", (data, textStatus, xhr) ->
      Cataract.Torrent.refreshFromHashes data.torrents
      true
