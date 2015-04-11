Cataract.DeleteTorrentController = Ember.ObjectController.extend
  deletePayload: false
  askForPayloadBinding: 'content.payloadExists'
  actions:
    deleteTorrent: ->
      torrent = @get('content')
      back = =>
        @send('closeModal')
        # must move away from the torrent
        @transitionToRoute('application')

      if @get('deletePayload')
        torrent.clearPayload()?.then ->
          torrent.deleteRecord()
          torrent.save().then back
      else
        torrent.deleteRecord()
        torrent.save().then back
