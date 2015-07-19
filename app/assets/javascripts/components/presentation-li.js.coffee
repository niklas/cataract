Cataract.PresentationLiComponent = Ember.Component.extend
  tagName: 'li'
  role: 'presentation'

  classNameBindings: ['active']
  attributeBindings: ['role']
  active: -> @get 'childViews.firstObject.active'
