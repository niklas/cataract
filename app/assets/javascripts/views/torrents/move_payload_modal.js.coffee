Cataract.MoveTorrentView = Ember.View.extend
  directoriesBinding: 'parentView.directories'
  disksBinding: 'parentView.disks'
  template: Ember.Handlebars.compile """
    {{#with view.parentView.move}}
      {{view Cataract.SelectDirectoryField valueBinding="targetDirectory" label="Directory"}}
      {{view Cataract.SelectDiskField valueBinding="targetDisk" label="Disk"}}
    {{/with}}
  """

Cataract.MovePayloadModal = Bootstrap.ModalPane.extend
  heading: "Move payload"
  directories: Ember.A()
  disks: Ember.A()
  torrent: null
  move: {}
  bodyViewClass: Cataract.MoveTorrentView
  primary: "Move"
  secondary: "Cancel"
  showBackdrop: true
  callback: (opts) ->
    if opts.primary
      record = Cataract.Move.createRecord @get('move')
      record.store.commit()
    true

