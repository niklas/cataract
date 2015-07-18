url = ->
  l = window.location

  if l.hostname is 'localhost' or l.hostname is '127.0.0.1'
    'http://localhost:4567/subscribe'
  else
    "#{l.protocol}//#{l.host}/subscribe"

Ember.Application.initializer
  name: 'subscription' # to server side events
  # subscribe to it from a controller with
  # @get('serverEvents.source').addEventListener <channel>, (event)->
  #   # do something with event.data
  after: 'store'

  initialize: (container, application)->
    source = new EventSource(url())
    source.addEventListener 'message', (event)->
      parsed = JSON.parse(event.data)
      console?.debug 'message', event.id, parsed

    application.register 'subscription:main', Ember.Object.extend(source: source)
    application.inject('controller', 'serverEvents', 'subscription:main')

    store = container.lookup('store:main')

    # model: singular model name, for example 'torrent'
    source.addModelEventListener = (model)->
      source.addEventListener model, (event)->
        parsed = JSON.parse(event.data)
        if 'object' is Ember.typeOf(parsed)
          if (attr = parsed[model]) and (have = store.recordForId(model, attr.id))
            have = have.get('updatedAt')
            fresh = attr.updated_at
            if have and fresh and fresh < have
              return # skip update, is out of date
          store.pushPayload model, parsed

      source.addEventListener 'delete_' + model, (event)->
        parsed = JSON.parse(event.data)
        if 'object' is Ember.typeOf(parsed)
          if (id = parsed.id) and (have = store.recordForId(model, parsed.id))
            have.unloadRecord()
