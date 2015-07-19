Cataract.instanceInitializer
  name: 'subscription' # to server side events
  # subscribe to it from a controller with
  # @get('serverEvents.source').addEventListener <channel>, (event)->
  #   # do something with event.data

  initialize: (instance)->

    subscription = instance.container.lookup('subscription:main')
    store = instance.container.lookup('service:store')

    Ember.assert 'event subscription could not be found', !!subscription
    Ember.assert 'store could not be found', !!store

    source = subscription.get('source')

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
