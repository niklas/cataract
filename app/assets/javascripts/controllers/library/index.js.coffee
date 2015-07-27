Cataract.LibraryIndexController = Ember.Controller.extend
  needs: ['application', 'disks']

  diskSorting: ['name']
  disks: Ember.computed.sort 'controllers.disks', 'diskSorting'


  # for the link to details
  directoryBinding: 'controllers.application.directory'
