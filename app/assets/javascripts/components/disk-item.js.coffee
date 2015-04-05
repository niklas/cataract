defaultTo = Ember.computed.oneWay

Cataract.DiskItemComponent = Ember.Component.extend
  content: null # disk
  label:     defaultTo 'content.name'
  isMounted: defaultTo 'content.isMounted'
  tagName: 'li'
  classNames: ['disk']
  classNameBindings: [
    'active'
    'isMounted:mounted:unmounted'
  ]

  activeBinding: 'childViews.firstObject.active'
