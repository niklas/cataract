Cataract.TorrentController = Ember.ObjectController.extend
  deletePayload: (torrent) ->
    Cataract.ClearPayloadModal.popup torrent: torrent

  move: (torrent) ->
    directory = torrent.get('payload.directory') || torrent.get('contentDirectory')
    Cataract.MovePayloadModal.popup
      torrent: torrent
      directories: @controllerFor('directories').get('content')
      disks: @controllerFor('disks').get('content')
      move: Ember.Object.create
        targetDisk: directory.get('disk.id')
        targetDirectory: directory.get('id')

  # TODO show in the third pane instead
  toggleExpand: (torrent) ->
    unless torrent.get('isExpanded')
      torrent.get('payload')
    torrent.set( 'isExpanded', ! torrent.get('isExpanded'))
    false

  start: (torrent) ->
    transfer = Cataract.Transfer.createRecord id: torrent.get('id')
    transfer.store.commit()
    false

  stop: (torrent) ->
    if transfer = torrent.get('transfer')
      transfer.deleteRecord()
      transfer.store.commit()
    false
