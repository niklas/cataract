Cataract.CreateDirectoryController = Ember.ObjectController.extend
  needs: ['disks']
  disksBinding: 'controllers.disks'
  directoriesBinding: 'content.disk.directories'

  actions:
    createDirectory: ->
      @get('content').save().then (dir) =>
        @send 'closeModal'
        @transitionToRoute 'directory', dir
