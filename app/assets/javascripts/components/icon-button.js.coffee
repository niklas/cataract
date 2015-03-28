Cataract.IconButtonComponent = Ember.Component.extend
  tagName: 'button'
  icon: 'oil'
  severity: 'normal'
  name: Ember.computed.readOnly 'icon'
  classNames: ['btn']
  classNameBindings: ['severityClass']

  iconClass: Ember.computed 'icon', ->
    "glyphicon-#{@get 'icon'}"

  severityClass: Ember.computed 'severity', ->
    "btn-#{@get 'severity'}"

