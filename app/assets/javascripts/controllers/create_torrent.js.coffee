Cataract.CreateTorrentController = Ember.ObjectController.extend
  needs: ['settings', 'disks', 'directories']
  directoriesBinding: 'controllers.directories.polies'
  disksBinding: 'controllers.disks'

  # Future Torrent attributes
  url:                    null
  contentPolyDirectory:   null
  filename:               null
  filedata:               null

  actions:
    createTorrent: ->
      torrent = @get('store').createRecord 'torrent',
        fetchAutomatically: true
        startAutomatically: true
      torrent.setProperties @getProperties(
        'url'
        'contentPolyDirectory'
        'filename'
        'filedata'
      )
      torrent.get('errors').clear()
      torrent.save().then (t)=>
        @set 'url', null
        @set 'filename', null
        @set 'filedata', null
        @transitionToRoute queryParams: { adding: false }
    cancel: ->
      @transitionToRoute queryParams: { adding: false }
