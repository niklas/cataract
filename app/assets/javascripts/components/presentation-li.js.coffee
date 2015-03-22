Cataract.PresentationLiComponent = Ember.Component.extend
  tagName: 'li'
  role: 'presentation'

  classNameBindings: ['active']
  attributeBindings: ['role']
  activeBinding: 'childViews.firstObject.active'
