Cataract.ModalDialogComponent = Ember.Component.extend
  heading: ''
  primary: 'Save changes'
  secondary: 'Close'
  classNames: 'modal fade in'.w()
  didInsertElement: ->
     @$().modal 'show'
  willDestroyElement: ->
    @$().modal 'hide'
  actions:
    close: -> @sendAction()
