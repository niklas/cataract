Cataract.AddTorrentView = Ember.View.extend
  templateName: 'torrents/add'
  directoriesBinding: 'parentView.directories'
  disksBinding: 'parentView.disks'

Cataract.AddTorrentModal = Cataract.ModalPane.extend
  directoriesBinding: 'controller.controllers.directories.poly.directories'
  disksBinding: 'controller.controllers.disks'
  torrent: null

  heading: "Add Torrent"
  bodyViewClass: Cataract.AddTorrentView
  primary: "Add"
  secondary: "Cancel"
