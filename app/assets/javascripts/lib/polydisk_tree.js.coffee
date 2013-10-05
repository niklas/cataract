slash = /\//

PolyDiskTree = Ember.Object.extend
  init: ->
    @_super()

    @get('directories').addEnumerableObserver(@,
      willChange: @willChangeDirectories,
      didChange:  @didChangeDirectories
    )

  root: Ember.computed ->
    PolyDiskDirectory.create()
  .property()

  directories: Ember.computed ->
    Ember.A()
  .property()


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
      dir.set('poly', here)
    else if dirPath.indexOf(herePath) is 0 # dir is sub of here
      if herePath.length is 0 # we are at root, just use first component
        nameOnDisk = dirPath.split(slash)[0]
      else
        cut = dirPath.slice( herePath.length + 1 ) # dir path from here (+ slash)
        nameOnDisk = cut.split(slash)[0]

      @_insert here.getOrBuildChildByNameOnDisk(nameOnDisk), dir

    else

window.PolyDiskTree = PolyDiskTree
