Cataract.AddTorrentController = Ember.ObjectController.extend
  needs: ['settings']
  setDefaultDirectory: (->
    settings = @get('controllers.settings.content')
    if settings?.get('hasValue')
      @get('content').set('contentDirectory', settings.get('incomingDirectory') )
  ).observes('controllers.settings.content.incomingDirectory')
