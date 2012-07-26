jQuery ->
  window.Cataract = Ember.Application.create
    rootElement: '#container'

  Cataract.Hello = Ember.View.create
    templateName: 'say-hello'
    name: "Spaghettimonster"

  Cataract.Hello.appendTo('#container')
