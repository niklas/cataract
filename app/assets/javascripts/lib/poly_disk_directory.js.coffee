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



window.PolyDiskDirectory = PolyDiskDirectory
