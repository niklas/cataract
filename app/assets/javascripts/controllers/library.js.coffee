alias = Ember.computed.alias

Cataract.LibraryController = Ember.Controller.extend
  needs: [
    'application'
  ]

  polyBinding: 'controllers.application.poly'
