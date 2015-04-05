Cataract.DirectoryOnlineRoute = Ember.Route.extend
  model: ->
    dir = @modelFor('directory')
    @store.find 'remote-torrent', directory_id: dir.get('id')

  actions:
    createFromRemote: (remote)->
      torrent = @get('store').createRecord(
        'torrent'
        title:              remote.get('title')
        url:                remote.get('uri')
        contentDirectory:   @modelFor('directory')
        fetchAutomatically: true
        startAutomatically: true
      )
      torrent.save().then (t)->
        remote.set 'torrent', t
      , ->
        torrent.rollback()
