alias = Ember.computed.alias

Cataract.LibraryController = Ember.Controller.extend
  needs: [
    'application'
    'directories'
    'disks'
  ]

  polyBinding: 'controllers.application.poly'
  disks: Ember.computed 'poly', 'poly.@each.alternatives.disk', ->
    if @get('poly')
      @get('poly.alternatives').mapProperty('disk')
    else
      @get('controllers.disks')

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
