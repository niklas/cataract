alias = Ember.computed.alias

Cataract.LibraryController = Ember.Controller.extend
  needs: [
    'application'
    'directories'
  ]

  polyBinding: 'controllers.application.poly'
  diskBinding: 'controllers.application.disk'
  directoryBinding: 'controllers.application.directory'

  rootDirectoriesBinding: 'controllers.directories'
  noDirectory: Ember.computed.not 'directory'
  diskNavVisible: Ember.computed.and 'poly', 'noDirectory'

  locationDidChange: (->
    if directory = @get('directory')
      Ember.run.later =>
        @transitionToRoute 'directory', directory
    else if disk = @get('disk')
      Ember.run.later =>
        @transitionToRoute 'disk', disk
  ).observes('directory', 'disk')
