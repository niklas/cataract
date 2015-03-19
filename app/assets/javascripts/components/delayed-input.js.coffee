Cataract.DelayedInputComponent = Ember.TextField.extend
  # bind value like in a normal input
  delay: 300
  fireAtStart: false

  _elementValueDidChange: ->
    console?.debug 'debouncing', this, @_setValue, @get('delay'), @get('fireAtStart')
    Ember.run.debounce this, @_setValue, @get('delay'), @get('fireAtStart')

  _setValue: ->
    @set 'value', @$().val()

