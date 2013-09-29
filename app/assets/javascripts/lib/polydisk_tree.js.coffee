slash = /\//

PolyDiskTree = Ember.Object.extend
  init: ->
    @_super()
    @setProperties
      root: PolyDiskDirectory.create()

    unless @get('directories')
      @setProperties
        directories: Ember.A()

    @get('directories').addEnumerableObserver(@,
      willChange: @willChangeDirectories,
      didChange:  @didChangeDirectories
    )


  willChangeDirectories: (directories, removing, addCount) ->
    # TODO

  didChangeDirectories: (directories, removeCount, adding) ->
    adding.forEach (dir, index) ->
      @_insert @get('root'), dir
    , @

  _insert: (here, dir) ->
    herePath = here.get('relativePath')
    dirPath  = dir.get('relativePath')
    if herePath is dirPath # dir is an alternative of here
      here.get('alternatives').addObject dir
    else if dirPath.indexOf(herePath) is 0 # dir is sub of here
      if herePath.length is 0 # we are at root, just use first component
        name = dirPath.split(slash)[0]
      else
        cut = dirPath.slice( herePath.length + 1 ) # dir path from here (+ slash)
        name = cut.split(slash)[0]

      @_insert here.getOrBuildChildByName(name), dir

    else

window.PolyDiskTree = PolyDiskTree
