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
