alias = Ember.computed.alias

Cataract.LibraryController = Ember.Controller.extend
  needs: [
    'application'
  ]

  polyBinding: 'controllers.application.poly'
  diskBinding: 'controllers.application.disk'
  directoryBinding: 'controllers.application.directory'

  noDirectory: Ember.computed.not 'directory'
  diskNavVisible: Ember.computed.and 'poly', 'noDirectory'

  locationDidChange: (->
    if directory = @get('directory')
      @transitionToRoute 'directory', directory
    else if disk = @get('disk')
      @transitionToRoute 'disk', disk
  ).observes('directory', 'disk')
