alias = Ember.computed.alias

Cataract.DirectoryController = Ember.ObjectController.extend
  needs: [
    'library'
  ]

  actions:
    subscribe: (model)->
      model.set 'subscribed', true
    unsubscribe: (model)->
      model.set 'subscribed', false

  poly: alias 'content.poly'
