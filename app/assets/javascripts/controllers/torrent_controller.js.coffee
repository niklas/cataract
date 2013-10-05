Cataract.TorrentController = Ember.ObjectController.extend
  needs: ['torrents', 'directories', 'disks']
  deletePayload: (torrent) ->
    Cataract.ClearPayloadModal.popup torrent: torrent

  actions:
    move: (torrent) ->
      directory = torrent.get('payload.directory') || torrent.get('contentDirectory')
      # TODO group directories by relative_path and show only one
      Cataract.MovePayloadModal.popup
        torrent: torrent
        directories: @get('controllers.directories.poly.directories')
        disks: @get('controllers.disks').get('content')
        move: Cataract.Move.createRecord
          targetDisk: directory.get('disk')
          targetDirectory: directory

    start: (torrent) ->
      transfer = torrent.get('transfers').createRecord()
      transfer.set('torrent', torrent)
      transfer.one 'didFinishSaving', ->
        torrent.set 'status', 'running'
      transfer.save()
      false

    stop: (torrent) ->
      if transfer = torrent.get('transfer')
        transfer.destroyRecord().then ->
          torrent.set 'status', 'archived'
      false

    delete: (torrent) ->
      Cataract.DeleteTorrentModal.popup
        torrent: torrent
