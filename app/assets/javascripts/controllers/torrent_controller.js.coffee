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
      torrent.get('transfer').then (transfer)->
        transfer.deleteRecord()
        transfer.save().then ->
          torrent.set 'status', 'archived'
      false
