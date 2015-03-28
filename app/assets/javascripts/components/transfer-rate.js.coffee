Cataract.TransferRateComponent = Ember.Component.extend
  content:   0
  tagName:   'span'
  direction: 'up'
  isActive:   false
  classNames: ['badge', 'rate']
  decimals:   0

  classNameBindings: ['direction']

  icon: Ember.computed 'direction', ->
    "glyphicon-arrow-#{@get 'direction'}"

  quantifiedContent: Ember.computed 'contentWithQuantification', 'decimals', ->
    @get('contentWithQuantification').val.toFixed(@get('decimals'))

  factor: Ember.computed 'contentWithQuantification', ->
    @get('contentWithQuantification').factor

  contentWithQuantification: Ember.computed 'content', ->
    # base 1000 so we always have <= 3 digits before the dot
    quantify @get('content'), base: 1000

  unit: 'B/s'

