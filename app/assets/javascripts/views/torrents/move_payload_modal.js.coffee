Cataract.MoveTorrentView = Ember.View.extend
  directoriesBinding: 'parentView.directories'
  disksBinding: 'parentView.disks'
  template: Ember.Handlebars.compile """
    {{#with view.parentView.move}}
      {{view Cataract.SelectDirectoryField selectionBinding="targetDirectory" label="Directory"}}
      {{view Cataract.SelectDiskField selectionBinding="targetDisk" label="Disk"}}
    {{/with}}
  """

Cataract.MovePayloadModal = Bootstrap.ModalPane.extend
  directories: Ember.A()
  disks: Ember.A()
  torrent: null
  move: {}

  heading: "Move payload"
  bodyViewClass: Cataract.MoveTorrentView
  primary: "Move"
  secondary: "Cancel"
  showBackdrop: true
  callback: (opts) ->
    if opts.primary
      move =  @get('move')
      move.set('torrent', @get('torrent'))
      move.get('transaction').commit()
    else
      move.get('transaction').rollback()
    true

