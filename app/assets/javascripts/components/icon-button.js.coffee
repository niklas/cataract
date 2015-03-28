Cataract.IconButtonComponent = Ember.Component.extend
  tagName: 'button'
  icon: 'oil'
  severity: 'normal'
  name: Ember.computed.oneWay 'icon'
  param: null # for action
  classNames: ['btn']
  classNameBindings: ['severityClass', 'name']

  iconClass: Ember.computed 'icon', ->
    "glyphicon-#{@get 'icon'}"

  severityClass: Ember.computed 'severity', ->
    "btn-#{@get 'severity'}"

  click: ->
    @sendAction('action', @get('param'))

