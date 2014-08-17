Cataract.TorrentsView = Ember.CollectionView.extend
  tagName: "ul"
  elementId: "torrents"
  classNames: "torrents"
  contentBinding: 'controller'
  itemViewClass:
    Ember.computed ->
      if @get('controller.mode') is 'library'
        Cataract.CircleTorrentView
      else
        Cataract.ItemTorrentView
    .property('controller.mode')
