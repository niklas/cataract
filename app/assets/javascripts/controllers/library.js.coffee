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
        @get('store').find 'torrent', directory_id: directory.id, with_content: true
        @transitionToRoute 'directory', directory
    else if poly = @get('poly')
      Ember.run.later =>
        dirIds = poly.get('alternatives').mapProperty('id').join(',')
        @get('store').find 'torrent', directory_id: dirIds, with_content: true
    else if disk = @get('disk')
      Ember.run.later =>
        @transitionToRoute 'disk', disk
    else
      Ember.run.later =>
        @transitionToRoute 'library.index'

  ).observes('directory', 'disk', 'poly')
