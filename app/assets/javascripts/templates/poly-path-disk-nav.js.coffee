Cataract.PolyPathDiskNavComponent = Ember.Component.extend
  content:    null  # poly
  targetRoute: 'directory'
  classNames: ['disk-nav']

  firstAlternative: Ember.computed.alias 'content.alternatives.firstObject'
