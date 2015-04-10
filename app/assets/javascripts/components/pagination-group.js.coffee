Cataract.PaginationGroupComponent = Ember.Component.extend
  tagName: 'ul'

  hasPrevious: false
  hasNext: false

  isVisible: Ember.computed.or 'hasPrevious', 'hasNext'

  previous: 'unspecifiedPreviousAction'
  next:     'unspecifiedNextAction'

  actions:
    previous: -> @sendAction 'previous'
    next:     -> @sendAction 'next'
