Cataract.DirectoryIndexRoute = Ember.Route.extend
  afterModel: (model)->
    if model.get('hasSubDirs')
      @transitionTo 'directory.children', model
