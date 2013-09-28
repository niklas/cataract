slash = /\//

PolyDiskDirectory = Ember.Object.extend
  relative_path: ''
  init: ->
    @setProperties
      alternatives: Ember.A()
      children: Ember.A()

  name: Ember.computed -> # last element of relative_path
    comps = @get('relative_path').split(slash)
    comps[ comps.length - 1 ]
  .property('relative_path')

PolyDiskTree = Ember.Object.extend
  init: ->
    @_super()
    @setProperties
      root: PolyDiskDirectory.create()
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
      if dirPath.indexOf('/') < 0 # direct child
        name = dirPath
      else
        cut = dirPath.slice( herePath.length + 1 ) # dir path from here (+ slash)
        name = cut[0]
      console?.debug "new child under #{herePath}: #{name}"

      child = here.get('children').findProperty('name', name)
      unless child?
        child = PolyDiskDirectory.create(relative_path: if cut? then "#{herePath}/#{name}" else name)
        here.get('children').pushObject child
      @_insert child, dir

    else
      console?.debug "cannot insert #{dirPath} at #{herePath}"

window.PolyDiskTree = PolyDiskTree
