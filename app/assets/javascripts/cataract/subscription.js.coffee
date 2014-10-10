Cataract.initializer
  name: 'subscription' # to server side events
  # subscribe to it from a controller with
  # @get('serverEvents.source').addEventListener <channel>, (event)->
  #   # do something with event.data

  initialize: (container, application)->
    source = new EventSource('http://localhost:4567/subscribe')
    source.addEventListener 'message', (event)->
      parsed = JSON.parse(event.data)
      console?.debug 'message', event.id, parsed

    application.register 'subscription:main', Ember.Object.extend(source: source)
    application.inject('controller', 'serverEvents', 'subscription:main')
