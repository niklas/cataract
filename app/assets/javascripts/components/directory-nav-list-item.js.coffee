Cataract.DirectoryNavListItemComponent = Ember.Component.extend
  isUnfiltered: true
  torrents: null

  tagName: 'li'
  classNames: ['directory']
  classNameBindings: ['active', 'content.exists:existing:missing']
  activeBinding: 'childViews.firstObject.active'
  isVisible: Ember.computed.or('hasResults', 'isUnfiltered')
  hasResults:
    Ember.computed ->
      torrents = @get('torrents.arrangedContent')
      @get('content.descendantsAndSelf').any (a)->
        torrents.isAny('contentPolyDirectory', a)
    .property('torrents.arrangedContent.@each.contentPolyDirectory', 'content.descendantsAndSelf.@each')

