slash = /\//

PolyDiskDirectory = Ember.Object.extend
  relativePath: ''
  alternatives: null
  children: null
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

  hasSubDirs: Ember.computed ->
    @get('children.length') > 0 or @get('alternatives').any (alt) -> alt.get('hasSubDirs')
  .property('alternatives.@each.hasSubDirs', 'children.length')



window.PolyDiskDirectory = PolyDiskDirectory
