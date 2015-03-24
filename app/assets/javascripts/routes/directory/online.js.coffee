Cataract.DirectoryOnlineRoute = Ember.Route.extend
  model: ->
    dir = @modelFor('directory')
    @store.find 'remote-torrent', directory_id: dir.get('id')
