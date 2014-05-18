Cataract.StatusMessageComponent = Ember.Component.extend
  classNames: ['status-message']
  isOnline: false
  errorMessage: ''
  actions:
    refreshStatus: ->
      @sendAction('refresh')

