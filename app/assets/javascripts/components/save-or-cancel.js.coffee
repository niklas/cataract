Cataract.SaveOrCancelComponent = Ember.Component.extend
  content: null
  classNames: ['btn-group']
  isVisibleBinding: 'content.isDirty'

  saveAction: 'save'
  cancelAction: 'cancel'

  actions:
    save: -> @sendAction 'saveAction', @get('content')
    cancel: -> @sendAction 'cancelAction', @get('content')


