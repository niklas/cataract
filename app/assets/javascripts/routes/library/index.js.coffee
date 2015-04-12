Cataract.LibraryIndexRoute = Ember.Route.extend
  redirect: ->
    app = @controllerFor 'application'
    if dir = app.get('dir')
      @transitionTo 'directory', dir
    else if disk = app.get('disk')
      @transitionTo 'disk', disk
    else unless app.get('poly')
      @transitionTo queryParams: { path: '' }
