slash = /\//

Cataract.DirectoriesController = Ember.ArrayController.extend Cataract.PolyDiskTreeMixin,
  needs: [
    'application',
    'torrents',
  ]
  isFiltered: Ember.computed.alias('controllers.application.filterDirectories')
  currentPath: Ember.computed.alias('controllers.application.path')
  isUnfiltered: Ember.computed.not('isFiltered')
  rootsBinding: 'root.children'

  contentBinding: 'roots'
  isLoaded: Ember.computed.not('directories.isPending')

  findPolyByPath: (path)->
    if found = @_super(path)
      # activate directory when poly has only one alternative
      alts = found.get('alternatives')
      if alts.get('length') == 1
        @set 'current', alts.get('firstObject')

    found

  hasCurrentPath:
    Ember.computed ->
      @get('currentPath.length') > 0
    .property('currentPath')
