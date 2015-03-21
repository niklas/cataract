Cataract.DiskItemComponent = Ember.Component.extend
  label: '<label>'
  isMounted: false
  target: null # a model to link to
  targetRoute: 'disk' # the route for the target
  tagName: 'li'
  classNames: ['disk']
  classNameBindings: [
    'active'
    'isMounted:mounted:unmounted'
  ]

  activeBinding: 'childViews.firstObject.active'
