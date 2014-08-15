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
          targetDisk: directory.get('disk')
          targetDirectory: directory
        @set 'move', move
  ).observes('content').on('init')
  actions:
    movePayload: ->
      move = @get('store').createRecord 'move', @get('move')
      move.set('torrent', @get('content'))
      move.save().then (m)=>
        @send('closeModel')

