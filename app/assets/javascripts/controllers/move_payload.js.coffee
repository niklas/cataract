Cataract.MovePayloadController = Ember.ObjectController.extend
  needs: ['directories', 'disks']
  directoriesBinding: 'controllers.directories.polies'
  disksBinding: 'controllers.disks'
  move: {}
  setMove: (->
    Ember.run.once =>
      directory = @get('content.payload.directory') || @get('content.contentDirectory')
      if directory
        move = @get('store').createRecord 'move',
          done: false,
          torrent: @get('content')
          targetDisk: directory.get('disk')
          targetDirectory: directory
        @set 'move', move
  ).observes('content').on('init')
  actions:
    movePayload: ->
      @get('move').save().then (move)=>
        @send('closeModal')

