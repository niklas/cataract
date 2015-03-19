Cataract.PayloadDetailsComponent = Ember.Component.extend
  classNames: ['payload']
  isShowingFiles: false

  actions:
    toggleFiles: (event) ->
      @toggleProperty 'isShowingFiles'
      false
