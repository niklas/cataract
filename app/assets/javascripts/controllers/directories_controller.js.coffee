slash = /\//

Cataract.DirectoriesController = Ember.ArrayController.extend PolyDiskTree,
  needs: ['torrents']
  rootsBinding: 'root.children'
  currentBinding: 'controllers.torrents.directory'
  isLoadedBinding: 'directories.length'

  contentBinding: 'roots'

  init: ->
    @_super()
    @set 'directories', @get('store').findAll('directory')

