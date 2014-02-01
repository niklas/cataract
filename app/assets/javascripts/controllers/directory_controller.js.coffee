Cataract.DirectoryController = Ember.ObjectController.extend
  actions:
    subscribe: (model)->
      model.set 'subscribed', true
    unsubscribe: (model)->
      model.set 'subscribed', false
