Ember.DelayedTextField = Ember.TextField.extend
  delayedValue: null
  timeout: null
  delay: 300
  keyUp: (event) ->
    clearTimeout @get('timeout')
    @set 'timeout', setTimeout( (field) ->
      field.set('delayedValue', field.get('value'))
    , @get('delay'), this
    )
    true

  keyDown: (event) ->
    clearTimeout @get('timeout')
    true
