Cataract.NewDirectoryRoute = Ember.Route.extend
  model: ->
    app = @controllerFor('application')
    Ember.Object.create
      disk:            @modelFor('disk') || app.get('diskObject')
      parentDirectory: @modelFor('directory') || app.get('directory')
      virtual: false

  setupController: (controller, model) ->
    @_super(controller, model)
    @send 'openModal', 'create_directory', model
