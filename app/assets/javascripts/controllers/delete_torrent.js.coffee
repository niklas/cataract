Cataract.DeleteTorrentController = Ember.ObjectController.extend
  deletePayload: false
  askForPayloadBinding: 'content.payloadPresent'
  actions:
    deleteTorrent: ->
      torrent = @get('content')
      back = =>
        @send('closeModal')
        # must move away from the torrent
        @transitionToRoute('application')

      if @get('deletePayload')
        torrent.clearPayload()?.then ->
          torrent.destroy().then back
      else
        torrent.destroy().then back
