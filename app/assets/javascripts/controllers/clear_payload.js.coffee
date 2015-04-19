Cataract.ClearPayloadController = Ember.ObjectController.extend
  clearWithSize: Ember.computed 'payload.size', ->
    q = quantify @get('payload.size')
    "Clear #{q.val.toFixed(1)} #{q.factor}iB"
  actions:
    clearPayload: ->
      @get('content').clearPayload().then =>
        @send('closeModal')
      , (x)->
        console?.debug 'could not clear payload', x

