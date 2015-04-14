slash = /\//

PolyDiskTree = Ember.Mixin.create
  # Entry point, all directories, unstructed
  #
  # accepts a collection, for example a findAll
  # sets observers on it
  directories:
    Ember.computed (key, value) ->
      if arguments.length > 1
        @_setupObservers(value)
        @set('_directories', value)
      unless @get('_directories')
        fresh = Ember.A()
        @_setupObservers(fresh)
        @set('_directories', fresh)
      @set('polies', Ember.A()) # linear list
      @get('_directories')
    .property()

  # exit point, responds to #children and each to #alternatives
  root:
    Ember.computed ->
      PolyDiskDirectory.create()
    .property()

  polies: Ember.A()
  findPolyByPath: (path)->
    @get('polies').findBy 'relativePath', path

  _setupObservers: (list)->
    list.addEnumerableObserver(@,
      willChange: @_willChangeDirectories,
      didChange:  @_didChangeDirectories
    )


  _willChangeDirectories: (directories, removing, addCount) ->
    # TODO

  # a simple createRecord on store calls this before saving
  _didChangeDirectories: (directories, removeCount, adding) ->
    adding.forEach (dir, index) ->
      unless dir.get('isDirty')
        if dir.get('isLoaded')
          @_insert @get('root'), dir
        else
          dir.then =>
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

      child = here.getOrBuildChildByNameOnDisk(nameOnDisk)
      list = @get('polies')
      list.pushObject(child) unless list.indexOf(child) >= 0
      @_insert child, dir

    else

window.PolyDiskTree = PolyDiskTree
