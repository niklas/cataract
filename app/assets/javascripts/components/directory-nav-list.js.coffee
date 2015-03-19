Cataract.DirectoryNavListComponent = Ember.Component.extend
  tagName: 'ul'
  classNames: [
    'nav'
    'nav-pills'
    'nav-stacked'
    'directories'
  ]
  header: false
  content: null
  # just passed through to item
  isUnfiltered: true
  torrents: null
