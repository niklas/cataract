attr = DS.attr

Cataract.Torrent = DS.Model.extend
  title: attr 'string'
  transferBinding: 'transfers.firstObject'
  transfers: attr('Cataract.Transfer', collection: true)
  info_hash: attr 'string'
  status: attr 'string'
  filename: attr 'string'
  url: attr 'string'
  payloadExists: attr 'boolean'
  isRunning: (-> @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')

  filedata: attr 'string' # TODO put into payload

  payload: null
  payloadPresent: Ember.computed ->
    @get('payloadExists') and @get('payload.isLoaded') and !@get('payload.isDeleted')
  .property('payload.isLoaded', 'payload.isDeleted')

  # fetch manually because Emu cannot handle singleton resources
  loadPayload: ->
    id = @get 'id'
    serializer = @get('store')._adapter._serializer
    $.getJSON("/torrents/#{id}/payload")
      .success (data) =>
        payload = Cataract.Payload.createRecord(id: id)
        serializer.deserializeModel(payload, data, true)
        @set 'payload', payload

  contentDirectoryId: attr 'number'
  contentDirectory: DS.belongsTo('directory', key: 'contentDirectoryId')

  fetchAutomatically: attr 'boolean'
  startAutomatically: attr 'boolean'

Cataract.Torrent.reopenClass
  url: 'torrent'
  refreshFromHashes: (hash) ->
    for field in hash
      @get('store').find('torrent', field.id).then (record)->
        record.setProperties field if record?
    true
