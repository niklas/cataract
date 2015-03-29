Cataract.PolyPathDiskNavComponent = Ember.Component.extend
  content:    null  # poly
  targetRoute: 'directory'

  firstAlternative: Ember.computed.alias 'content.alternatives.firstObject'
