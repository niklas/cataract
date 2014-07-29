Cataract.DeleteTorrentController = Ember.ObjectController.extend
  deletePayload: true
  actions:
    deleteTorrent: ->
      torrent = @get('content')
      if @get('deletePayload')
        torrent.clearPayload()?.then ->
          torrent.destroyRecord()
      else
        torrent.destroyRecord()
      @send('closeModal')
