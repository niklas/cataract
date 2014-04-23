Cataract.DirectoryController = Ember.ObjectController.extend
  needs: ['application']

  content:
    Ember.computed (key, value)->
      if arguments.length > 1
        @set '_model', value
      if dir = @get('controllers.application.directory') # by setting path through query params
        dir
      else
        @get '_model'
    .property('controllers.application.directory')


  actions:
    subscribe: (model)->
      model.set 'subscribed', true
    unsubscribe: (model)->
      model.set 'subscribed', false
