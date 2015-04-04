Cataract.TorrentItemComponent = Ember.Component.extend
  classNames: [
    'torrent'
    'row'
    'list-group-item'
    'clearfix'
  ]
  classNameBindings: ['active']
  tagName: 'li'
  activeBinding: 'childViews.firstObject.active'

  click: (e)->
    unless $(e.target).is('a')
      @$().find('a:first').click()
