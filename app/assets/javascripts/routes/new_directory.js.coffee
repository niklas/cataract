Cataract.NewDirectoryRoute = Ember.Route.extend
  model: ->
    app = @controllerFor('application')
    @get('store').createRecord 'directory',
      disk:            app.get('disk') || @modelFor('disk')
      parentDirectory: app.get('directory') || @modelFor('directory')
      virtual: false

  setupController: (controller, model) ->
    @_super(controller, model)
    @send 'openModal', 'create_directory', model
