Cataract.IconButtonComponent = Ember.Component.extend
  tagName: 'button'
  icon: 'oil'
  severity: 'normal'
  name: Ember.computed.alias 'icon'
  param: null # for action
  classNames: ['btn']
  classNameBindings: ['severityClass']

  iconClass: Ember.computed 'icon', ->
    "glyphicon-#{@get 'icon'}"

  severityClass: Ember.computed 'severity', ->
    "btn-#{@get 'severity'}"

  click: ->
    @sendAction('action', @get('param'))

