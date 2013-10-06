Cataract.MoveTorrentView = Ember.View.extend
  directoriesBinding: 'parentView.directories'
  disksBinding: 'parentView.disks'
  template: Ember.Handlebars.compile """
    {{#with view.parentView.move}}
      {{view Cataract.SelectDirectoryField selectionBinding="targetDirectory" label="Directory"}}
      {{view Cataract.SelectDiskField selectionBinding="targetDisk" label="Disk"}}
    {{/with}}
  """

# TODO group directories by relative_path and show only one
Cataract.MovePayloadModal = Cataract.ModalPane.extend
  directoriesBinding: 'controller.controllers.directories.poly.directories'
  disksBinding: 'controller.controllers.disks'
  torrent: null
  move: {}

  heading: "Move payload"
  bodyViewClass: Cataract.MoveTorrentView
  primary: "Move"
  secondary: "Cancel"
  ok: (opts)->
    move = @get('controller.store').createRecord 'move', @get('move')
    move.set('torrent', @get('torrent'))
    move.save()
