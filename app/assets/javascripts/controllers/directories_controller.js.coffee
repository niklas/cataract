slash = /\//

Cataract.DirectoriesController = Ember.ArrayController.extend PolyDiskTree,
  rootsBinding: 'root.children'
  current: null
  isLoadedBinding: 'directories.length'

  contentBinding: 'roots'

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
