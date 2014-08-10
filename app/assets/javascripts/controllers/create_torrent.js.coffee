Cataract.CreateTorrentController = Ember.ObjectController.extend
  needs: ['settings', 'disks', 'directories']
  directoriesBinding: 'controllers.directories.polies'
  disksBinding: 'controllers.disks'
  actions:
    createTorrent: ->
      torrent = @get('content')
      torrent.setProperties
        fetchAutomatically: true
        startAutomatically: true
      torrent.get('errors').clear()
      torrent.save().then (t)->
        @send('closeModal')
        @transitionToRoute 'torrent', t
    cancel: ->
      @get('content').deleteRecord()

  setDefaultDirectory: (->
    self = this
    @get('controllers.settings.content').then (settings)->
      self.get('content').set('contentDirectory', settings.get('incomingDirectory') )
  ).observes('content', 'controllers.settings.content.incomingDirectory')

