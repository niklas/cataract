Cataract.DirectoryController = Ember.ObjectController.extend
  needs: ['application']
  _directory: null # avoid stack overflow through proxy-method-missing

  content:
    Ember.computed (key, value)->
      if arguments.length > 1
        @set '_directory', value

      @get('_directory') ||
        @get('controllers.application.directory') # by setting path through query params
    .property('controllers.application.directory')


  actions:
    subscribe: (model)->
      model.set 'subscribed', true
    unsubscribe: (model)->
      model.set 'subscribed', false
