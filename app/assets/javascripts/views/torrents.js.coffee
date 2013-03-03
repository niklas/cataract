Cataract.TorrentsView = Ember.CollectionView.extend
  tagName: "ul"
  elementId: "torrents"
  classNames: "torrents"
  contentBinding: 'controller.filtered'
  itemViewClass: 'Cataract.ItemTorrentView'
