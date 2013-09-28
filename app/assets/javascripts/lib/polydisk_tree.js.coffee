PolyDiskDirectory = Ember.Object.extend
  init: ->
    @setProperties
      alternatives: Ember.A()
  relative_path: ''

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
    console.debug "willChange"

  didChangeDirectories: (directories, removeCount, adding) ->
    console.debug 'didChange'
    adding.forEach (dir, index) ->
      @get('root.alternatives').pushObject dir
    , @

window.PolyDiskTree = PolyDiskTree
