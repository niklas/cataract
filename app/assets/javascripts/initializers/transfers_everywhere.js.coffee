Ember.Application.initializer
  name: 'transfersEverywhere'
  after: 'subscription'
  initialize: (container, application) ->
    application.inject('route', 'transfers', 'controller:transfers')

