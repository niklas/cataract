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
    herePath = here.get('relative_path')
    dirPath  = dir.get('relative_path')
    if herePath is dirPath # dir is an alternative of here
      console?.debug "found alternative for #{herePath}"
      here.get('alternatives').pushObject dir
    else if dirPath.indexOf(herePath) is 0 # dir is sub of here
      console?.debug "new child under #{herePath}: #{dirPath}"
      if herePath.length is 0 # we are at root, just use first component
        name = dirPath.split(slash)[0]
      else
        cut = dirPath.slice( herePath.length + 1 ) # dir path from here (+ slash)
        name = cut.split(slash)[0]

      @_insert here.getOrBuildChildByName(name), dir

    else
      console?.debug "cannot insert #{dirPath} at #{herePath}"

window.PolyDiskTree = PolyDiskTree
