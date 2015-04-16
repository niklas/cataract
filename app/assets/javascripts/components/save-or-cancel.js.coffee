Cataract.SaveOrCancelComponent = Ember.Component.extend
  content: null
  classNames: ['btn-group']
  isVisibleBinding: 'content.isDirty'

  saveAction: 'save'
  cancelAction: 'cancel'

  actions:
    save: ->
      content = @get 'content'
      content = content.get 'content' if content.isController
      @sendAction 'saveAction', content
    cancel: ->
      content = @get 'content'
      content = content.get 'content' if content.isController
      @sendAction 'cancelAction', content


