Cataract.initializer
  name: 'transfersEverywhere'
  initialize: (container, application) ->
    application.inject('route', 'transfers', 'controller:transfers')

