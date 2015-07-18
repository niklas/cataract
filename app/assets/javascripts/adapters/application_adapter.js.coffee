Cataract.ApplicationAdapter = DS.ActiveModelAdapter.extend
  ajaxError: (jqxhr)->
    if jqxhr and jqxhr.status is 500
      Ember.Rails.flashMessages.createMessage
        severity: 'error'
        message: if jqxhr.responseJSON? then jqxhr.responseJSON.error else jqxhr.statusText
      # stop propagating
      false
    else
      @_super(jqxhr)

  # TODO only transfers
  shouldReloadAll: -> true
