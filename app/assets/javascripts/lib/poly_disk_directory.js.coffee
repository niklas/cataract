slash = /\//

PolyDiskDirectory = Ember.Object.extend
  relativePath: ''
  init: ->
    @_super()
    @setProperties
      alternatives: Ember.A()
      children: Ember.A()

  name: Ember.computed -> # last element of relativePath
    comps = @get('relativePath').split(slash)
    comps[ comps.length - 1 ]
  .property('relativePath')

  getOrBuildChildByName: (name) ->
    children = @get('children')
    path = @get('relativePath')
    child = children.findProperty('name', name)
    unless child?
      child = PolyDiskDirectory.create
        relativePath: (if path.length is 0 then name else "#{path}/#{name}")
      children.pushObject child
      console?.debug "build child: #{child.get('relativePath')}"
    child



window.PolyDiskDirectory = PolyDiskDirectory
