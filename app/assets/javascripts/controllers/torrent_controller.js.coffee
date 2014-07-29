Cataract.TorrentController = Ember.ObjectController.extend
  needs: ['torrents', 'directories', 'disks']

  actions:
    move: (torrent) ->
      directory = torrent.get('payload.directory') || torrent.get('contentDirectory')
      Cataract.MovePayloadModal.popup
        controller: this
        torrent: torrent
        move:
          targetDisk: directory.get('disk')
          targetDirectory: directory

    start: (torrent) ->
      transfer = @get('store').createRecord 'transfer',
        torrent: torrent
      transfer.save().then ->
        torrent.set 'status', 'running'
      false

    stop: (torrent) ->
      if transfer = torrent.get('transfer')
        transfer.destroyRecord().then ->
          torrent.set 'status', 'archived'
      false

    deletePayload: (torrent) ->
      Cataract.ClearPayloadModal.popup torrent: torrent
