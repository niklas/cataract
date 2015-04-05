Cataract.DirectoryRoute = Ember.Route.extend
  model: (params) ->
    @get('store').find 'directory', params.directory_id # FIXME ember should do this
  controllerName: 'directory'
  renderTemplate: ->
    @render 'directory'
  deactivate: (model)->
    @_super()
    @controllerFor('directory').set('content', null) # back to query-param

