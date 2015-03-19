Cataract.PaginationGroupComponent = Ember.Component.extend
  tagName: 'ul'

  previous: 'unspecifiedPreviousAction'
  next:     'unspecifiedNextAction'

  actions:
    previous: -> @sendAction 'previous'
    next:     -> @sendAction 'next'
