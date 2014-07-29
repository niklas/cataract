Cataract.DeleteTorrentController = Ember.ObjectController.extend
  deletePayload: false
  askForPayloadBinding: 'content.payloadPresent'
  actions:
    deleteTorrent: ->
      torrent = @get('content')
      back = =>
        @send('closeModal')
        # must move away from the torrent
        @transitionToRoute('torrents')

      if @get('deletePayload')
        torrent.clearPayload()?.then ->
          torrent.destroyRecord().then back
      else
        torrent.destroyRecord().then back
