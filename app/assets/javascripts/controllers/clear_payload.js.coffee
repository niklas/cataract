Cataract.ClearPayloadController = Ember.ObjectController.extend
  clearWithSize:
    Ember.computed ->
     "Clear #{@get('payload.humanSize')}"
    .property('payload.humanSize')
  actions:
    clearPayload: ->
      @get('content').clearPayload().then =>
        @send('closeModal')
      , (x)->
        console?.debug 'could not clear payload', x

