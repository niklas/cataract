Cataract.DirectoryNavListView = Ember.View.extend
  content: []
  templateName: 'directory/nav_list'
  tagName: 'ul'
  classNames: "nav nav-pills nav-stacked directories".w()

Cataract.DirectoryNavItemView = Ember.View.extend
  templateName: 'directory/nav_item'
  tagName: 'li'
  classNameBindings: ":directory active exists:existing:missing".w()
  existsBinding: 'content.exists'
  activeBinding: 'childViews.firstObject.active'
  isVisible: Ember.computed.or('hasResults', 'controller.isUnfiltered')

  hasResults:
    Ember.computed ->
      torrents = @get('controller.controllers.torrents.arrangedContent')
      @get('content.descendantsAndSelf').any (a)->
        torrents.isAny('contentPolyDirectory', a)
    .property('controller.controllers.torrents.arrangedContent.@each.contentPolyDirectory', 'content.descendantsAndSelf.@each')
