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
  callback: Ember.K
