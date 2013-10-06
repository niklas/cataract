Cataract.AddTorrentController = Ember.ObjectController.extend
  needs: ['settings', 'disks', 'directories']
  setDefaultDirectory: ->
    self = this
    @get('controllers.settings.content').then (settings)->
      self.get('content').set('contentDirectory', settings.get('incomingDirectory') )
