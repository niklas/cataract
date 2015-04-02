Cataract.TorrentItemComponent = Ember.Component.extend
  classNames: ['torrent']
  classNameBindings: ['active', 'row']
  tagName: 'li'
  activeBinding: 'childViews.firstObject.active'

  click: (e)->
    unless $(e.target).is('a')
      @$().find('a:first').click()
