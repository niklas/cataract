defaultTo = Ember.computed.oneWay

Cataract.DiskLinkComponent = Ember.Component.extend
  content: null # disk
  label:     defaultTo 'content.name'
  isMounted: defaultTo 'content.isMounted'
  targetRoute: 'disk' # the route for the target
  classNames: ['disk']
  classNameBindings: [
    'active'
    'isMounted:mounted:unmounted'
  ]

  activeBinding: 'childViews.firstObject.active'

