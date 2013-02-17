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
      # OPTIMIZE do not know how to properly implement "Cancel" when using
      # createRecord to early. Could wrap the whole modal box into a
      # transaction
      move =  @get('move')
      record = Cataract.Move.createRecord
        targetDirectory: Cataract.Directory.find(move.get('targetDirectory'))
        targetDisk:      Cataract.Disk.find(move.get('targetDisk'))
        torrent: @get('torrent')
      record.store.commit()
    true

