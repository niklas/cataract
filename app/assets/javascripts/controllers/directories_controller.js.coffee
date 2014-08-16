slash = /\//

Cataract.DirectoriesController = Ember.ArrayController.extend PolyDiskTree,
  needs: [
    'application',
    'torrents',
  ]
  isFiltered: Ember.computed.alias('controllers.application.filterDirectories')
  isUnfiltered: Ember.computed.not('isFiltered')
  rootsBinding: 'root.children'
  current: null

  contentBinding: 'roots'
  isLoaded: Ember.computed.not('directories.isPending')

  init: ->
    @_super()
    @set 'directories', @get('store').findAll('directory')

  findPolyByPath: (path)->
    if found = @_super(path)
      # activate directory when poly has only one alternative
      alts = found.get('alternatives')
      if alts.get('length') == 1
        @set 'current', alts.get('firstObject')

    found
