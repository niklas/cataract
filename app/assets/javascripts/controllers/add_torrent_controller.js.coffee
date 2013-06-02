Cataract.AddTorrentController = Ember.ObjectController.extend
  needs: ['settings']
  setDefaultDirectory: (->
    settings = @get('controllers.settings.content')
    if settings.get('hasValue')
      @get('content').set('contentDirectoryId', settings.get('incomingDirectoryId') )
  ).observes('controllers.settings.content.incomingDirectoryId')
