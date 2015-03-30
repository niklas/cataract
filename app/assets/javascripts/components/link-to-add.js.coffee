Cataract.LinkToAddComponent = Ember.Component.extend
  tagName: 'a'
  active: false
  classNameBindings: [
    'active'
  ]
  attributeBindings: [
    'href'
  ]
  href: '#/add'

  click: ->
    # yeah yeah, DDAU my ass
    @toggleProperty 'active'
    false
