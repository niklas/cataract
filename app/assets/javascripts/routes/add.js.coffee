Cataract.AddRoute = Ember.Route.extend
  model: -> @get('store').createRecord('torrent')
  setupController: (controller, torrent) ->
    @_super(controller, torrent)
    @controllerFor('settings').get('content').then (settings)=>
      @modelFor('add').set('contentPolyDirectory', settings.get('incomingDirectory.poly'))
    @send 'openModal', 'create_torrent', torrent

