Cataract.DeleteTorrentController = Ember.ObjectController.extend
  deletePayload: true
  actions:
    close: -> @send 'closeModal'
    submit: ->
      torrent = @get('content')
      if @get('deletePayload')
        torrent.clearPayload()?.then ->
          torrent.destroyRecord()
      else
        torrent.destroyRecord()
      @close()
