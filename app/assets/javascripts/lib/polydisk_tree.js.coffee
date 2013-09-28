slash = /\//

PolyDiskDirectory = Ember.Object.extend
  relative_path: ''
  init: ->
    @_super()
    @setProperties
      alternatives: Ember.A()
      children: Ember.A()

  name: Ember.computed -> # last element of relative_path
    comps = @get('relative_path').split(slash)
    comps[ comps.length - 1 ]
  .property('relative_path')

  getOrBuildChildByName: (name) ->
    children = @get('children')
    path = @get('relative_path')
    child = children.findProperty('name', name)
    unless child?
      child = PolyDiskDirectory.create
        relative_path: (if path.length is 0 then name else "#{path}/#{name}")
      children.pushObject child
      console?.debug "build child: #{child.get('relative_path')}"
    child


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
      console?.debug "new child under #{herePath}: #{dirPath}"
      if herePath.length is 0 # we are at root, just use first component
        name = dirPath.split(slash)[0]
      else
        cut = dirPath.slice( herePath.length + 1 ) # dir path from here (+ slash)
        name = cut.split(slash)[0]

      @_insert here.getOrBuildChildByName(name), dir

    else
      console?.debug "cannot insert #{dirPath} at #{herePath}"

window.PolyDiskDirectory = PolyDiskDirectory
window.PolyDiskTree = PolyDiskTree
