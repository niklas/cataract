Cataract.ModalDialogComponent = Ember.Component.extend
  heading: ''
  primary: 'Save changes'
  secondary: 'Close'
  classNames: 'modal fade in'.w()
  size: 'normal'
  sizeClass:
    Ember.computed ->
      switch @get('size')
        when 'normal' then null
        when 'small' then 'modal-sm'
        when 'large' then 'modal-lg'
        when 'big' then 'modal-lg'
    .property('size')
  cancel: 'closeModal'
  didInsertElement: ->
     @$().modal
       backdrop: 'static' # do not close on click
  willDestroyElement: ->
    @$().modal 'hide'
  actions:
    close: ->
      @sendAction('cancel')
    submit: ->
      @sendAction('action')
