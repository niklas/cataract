Cataract.RunningController = Ember.ArrayController.extend
  needs: [
    'application'
    'torrents'
  ]

  disksBinding: 'controllers.application.disks'
