Cataract.TorrentController = Ember.ObjectController.extend
  deletePayload: (torrent) ->
    Cataract.ClearPayloadModal.popup torrent: torrent

  move: (torrent) ->
    directory = torrent.get('payload.directory') || torrent.get('contentDirectory')
    # TODO group directories by relative_path and show only one
    Cataract.MovePayloadModal.popup
      torrent: torrent
      directories: @controllerFor('directories').get('unfilteredContent')
      disks: @controllerFor('disks').get('content')
      move: Cataract.Move.createRecord
        targetDisk: directory.get('disk')
        targetDirectory: directory

  start: (torrent) ->
    transaction = Cataract.store.transaction()
    transfer = transaction.createRecord Cataract.Transfer, id: torrent.get('id')
    transaction.commit()
    false

  stop: (torrent) ->
    if transfer = torrent.get('transfer')
      transfer.deleteRecord()
      transfer.get('transaction').commit()
    false

  delete: (torrent) ->
    Cataract.DeleteTorrentModal.popup
      torrent: torrent
