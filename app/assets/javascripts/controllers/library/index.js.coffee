Cataract.LibraryIndexController = Ember.Controller.extend
  needs: ['application', 'disks']

  diskSorting: ['name']
  disks: Ember.computed.sort 'controllers.disks', 'diskSorting'
