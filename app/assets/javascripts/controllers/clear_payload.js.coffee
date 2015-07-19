Cataract.ClearPayloadController = Ember.Controller.extend
  clearWithSize: Ember.computed 'model.payload.size', ->
    q = quantify @get('model.payload.size')
    "Clear #{q.val.toFixed(1)} #{q.factor}iB"
  actions:
    clearPayload: ->
      @get('content').clearPayload().then =>
        @send('closeModal')
      , (x)->
        console?.debug 'could not clear payload', x

