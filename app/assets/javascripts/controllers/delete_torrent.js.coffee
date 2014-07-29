Cataract.DeleteTorrentController = Ember.ObjectController.extend
  actions:
    close: -> @send 'closeModal'
