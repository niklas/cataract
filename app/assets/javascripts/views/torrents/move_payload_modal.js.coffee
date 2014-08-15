# TODO group directories by relative_path and show only one
Cataract.MovePayloadModal = Cataract.ModalPane.extend
  directoriesBinding: 'controller.controllers.directories.directories'
  disksBinding: 'controller.controllers.disks'
  torrent: null
  move: {}

  ok: (opts)->
    move = @get('controller.store').createRecord 'move', @get('move')
    move.set('torrent', @get('torrent'))
    move.save()
