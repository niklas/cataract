Cataract.TransfersController = Ember.ArrayController.extend
  needs: ['application']

  subscribeToPushes: (->
    @get('serverEvents.source').addEventListener 'transfers', (event)=>
      Ember.run =>
        having = @get('model')
        store =  @get('store')
        parsed = JSON.parse(event.data)
        if 'array' is Ember.typeOf(parsed)
          parsed.forEach (attrs)->
            if have = having.findProperty('infoHash', attrs.id)
              attrs.id = have.get('id')
              store.pushPayload 'transfer', { transfers: [attrs] }
  ).on('init')

  fetchTransfersInitially: (->
    @get('store').findAll('transfer').then (transfers)=>
      @set 'model', transfers
    , (jqxhr)=>
      @get('controllers.application').transfersError(jqxhr)
  ).on('init')
