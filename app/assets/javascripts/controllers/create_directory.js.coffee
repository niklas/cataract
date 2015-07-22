Cataract.CreateDirectoryController = Ember.Controller.extend
  needs: ['disks']
  disksBinding: 'controllers.disks'
  directoriesBinding: 'content.disk.directories'

  actions:
    createDirectory: ->
      dummy = @get('content')
      @get('store').createRecord('directory', dummy.getProperties(
        'disk'
        'directory'
        'virtual'
        'name'
        'parentDirectory'
        'showSubDirs'
        'subscribed'
        'filter'
      )).save().then (dir) =>
        @send 'closeModal'
        @transitionToRoute 'directory', dir
