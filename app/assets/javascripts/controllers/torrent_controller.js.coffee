Cataract.TorrentController = Ember.ObjectController.extend
  needs: ['torrents', 'directories', 'disks']

  actions:
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
