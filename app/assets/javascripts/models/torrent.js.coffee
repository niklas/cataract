Cataract.Torrent = Emu.Model.extend
  title: Emu.field 'string'
  transferBinding: 'transfers.firstObject'
  transfers: Emu.field('Cataract.Transfer', collection: true)
  info_hash: Emu.field 'string'
  status: Emu.field 'string'
  filename: Emu.field 'string'
  url: Emu.field 'string'
  payloadExists: Emu.field 'boolean'
  isRunning: (-> @get('status') == 'running').property('status')
  isRemote: (-> @get('status') == 'remote').property('status')

  filedata: Emu.field 'string' # TODO put into payload

  payload: (-> Cataract.Payload.find(@get('id'))).property()
  payloadPresent: Ember.computed ->
    @get('payloadExists') and @get('payload.isLoaded') and !@get('payload.isDeleted')
  .property('payload.isLoaded', 'payload.isDeleted')

  contentDirectoryId: Emu.field 'number'
  contentDirectory: Emu.belongsTo('Cataract.Directory', key: 'contentDirectoryId')

  fetchAutomatically: Emu.field 'boolean'
  startAutomatically: Emu.field 'boolean'

Cataract.Torrent.reopenClass
  url: 'torrent'
  refreshFromHashes: (hash) ->
    for field in hash
      record = Cataract.store.find(Cataract.Torrent, field.id)
      record.setProperties field if record?
    true
