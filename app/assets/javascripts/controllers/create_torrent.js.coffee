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
      torrent.save().then (t)=>
        @send('closeModal')
        @transitionToRoute 'torrent', t
    cancel: ->
      @get('content').deleteRecord()
