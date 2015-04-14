alias = Ember.computed.alias

Cataract.LibraryController = Ember.Controller.extend
  needs: [
    'application'
    'directories'
  ]

  polyBinding: 'controllers.application.poly'
  disksBinding: 'controllers.application.disks'

  diskBinding: 'controllers.application.disk'
  directoryBinding: 'controllers.application.directory'

  allRootDirectoriesBinding: 'controllers.directories.root.children'
  rootDirectories: Ember.computed 'allRootDirectories', 'disk', 'disk.@each.rootDirectories', ->
    if disk = @get('disk')
      @get('controllers.directories.directories')
        .filterProperty('parentDirectory', null)
        .filterProperty('disk.id', disk)
    else
      @get('allRootDirectories')
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
