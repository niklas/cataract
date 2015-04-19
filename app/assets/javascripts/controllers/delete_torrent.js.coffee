Cataract.DeleteTorrentController = Ember.ObjectController.extend
  deletePayload: false
  askForPayloadBinding: 'content.payloadExists'
  actions:
    deleteTorrent: ->
      torrent = @get('content')
      back = =>
        @send('closeModal')

      if @get('deletePayload')
        torrent.clearPayload()?.then ->
          torrent.deleteRecord()
          torrent.save().then back
      else
        torrent.deleteRecord()
        torrent.save().then back
