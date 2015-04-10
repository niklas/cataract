Cataract.StatusMessageComponent = Ember.Component.extend
  isOnline: false
  errorMessage: ''

  tagName: 'span'
  classNames: ['label']
  classNameBindings: ['labelSeverity']
  attributeBindings: ['title']

  labelSeverity: Ember.computed 'isOnline', ->
    if @get('isOnline')
      'label-success'
    else
      'label-danger'

  title: Ember.computed 'isOnline', 'errorMessage', ->
    unless @get('isOnline')
      @get('errorMessage')

  click: -> @sendAction()
