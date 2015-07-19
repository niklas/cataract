defaultTo = Ember.computed.oneWay

Cataract.DiskItemComponent = Ember.Component.extend
  content: null # disk
  label:     defaultTo 'content.name'
  isMounted: defaultTo 'content.isMounted'
  tagName: 'li'
  classNames: ['disk', 'list-group-item']
  classNameBindings: [
    'active'
    'isMounted:mounted:unmounted'
  ]

  statsVisible: true

  active: -> @get 'childViews.firstObject.active'
