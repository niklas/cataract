Cataract.AddTorrentView = Ember.View.extend
  templateName: 'torrents/add'
  directoriesBinding: 'parentView.directories'
  disksBinding: 'parentView.disks'

Cataract.AddTorrentModal = Bootstrap.ModalPane.extend
  directories: Ember.A()
  disks: Ember.A()
  torrent: null

  heading: "Add Torrent"
  bodyViewClass: Cataract.AddTorrentView
  primary: "Add"
  secondary: "Cancel"
  showBackdrop: true
  callback: (opts) ->
    if opts.primary
      torrent = @get('torrent')
      record = Cataract.Torrent.createRecord
        contentDirectory: torrent.get('contentDirectory')
        fetchAutomatically: true
        startAutomatically: true
        url: torrent.get('url')
        filedata: torrent.get('filedata')
        filename: torrent.get('filename')
      record.one 'didCreate', ->
        Cataract.get('torrentsController').didAddRunningTorrent(record)
      record.get('transaction').commit()
    true
