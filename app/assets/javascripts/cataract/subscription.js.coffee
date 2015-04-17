url = ->
  l = window.location

  if l.hostname is 'localhost' or l.hostname is '127.0.0.1'
    'http://localhost:4567/subscribe'
  else
    "#{l.protocol}//#{l.host}/subscribe"

Cataract.initializer
  name: 'subscription' # to server side events
  # subscribe to it from a controller with
  # @get('serverEvents.source').addEventListener <channel>, (event)->
  #   # do something with event.data

  initialize: (container, application)->
    source = new EventSource(url())
    source.addEventListener 'message', (event)->
      parsed = JSON.parse(event.data)
      console?.debug 'message', event.id, parsed

    application.register 'subscription:main', Ember.Object.extend(source: source)
    application.inject('controller', 'serverEvents', 'subscription:main')


    # model: singular model name, for example 'torrent'
    # store: store to push the changes into
    source.addModelEventListener = (model, store)->
      source.addEventListener model, (event)->
        parsed = JSON.parse(event.data)
        if 'object' is typeof(parsed)
          store.pushPayload model, parsed

