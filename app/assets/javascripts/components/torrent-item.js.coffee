Cataract.TorrentItemComponent = Ember.Component.extend
  classNames: ['torrent']
  classNameBindings: ['active']
  tagName: 'li'
  activeBinding: 'childViews.firstObject.active'
