Cataract.RecentController = Ember.ArrayController.extend
  needs: [
    'application'
  ]

  polyBinding: 'controllers.application.poly'
  disksBinding: 'controllers.application.disks'