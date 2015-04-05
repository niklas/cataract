Ember.Application.initializer
  name: 'torrentsEverywhere'
  initialize: (container, application) ->
    application.inject('route', 'torrents', 'controller:torrents')
