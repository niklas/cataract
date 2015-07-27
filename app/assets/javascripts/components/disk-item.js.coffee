defaultTo = Ember.computed.oneWay

Cataract.DiskItemComponent = Ember.Component.extend
  content: null # disk
  label:     defaultTo 'content.name'
  isMounted: defaultTo 'content.isMounted'
  tagName: 'li'
  classNames: ['disk', 'list-group-item']
  classNameBindings: [
    'isMounted:mounted:unmounted'
  ]

  statsVisible: true

  detailsVisible: Ember.computed.and 'statsVisible', 'content.id'
