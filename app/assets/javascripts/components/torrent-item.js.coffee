Cataract.TorrentItemComponent = Ember.Component.extend
  classNames: [
    'torrent'
    'row'
    'list-group-item'
    'clearfix'
  ]
  classNameBindings: [
    'active'
    'isCollapsed:collapsed:expanded'
  ]
  tagName: 'li'
  activeBinding: 'childViews.firstObject.active'
  isCollapsed: true

  click: (e) ->
    unless $(e.target).is('a,button')
      @toggleProperty 'isCollapsed'
