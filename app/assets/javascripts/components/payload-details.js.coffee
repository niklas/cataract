Cataract.PayloadDetailsComponent = Ember.Component.extend
  classNames: ['payload']
  isCollapsed: false
  isShowingFiles: false

  actions:
    toggleFiles: (event) ->
      @toggleProperty 'isShowingFiles'
      false
