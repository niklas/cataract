slash = /\//

SortedArray = Ember.ArrayProxy.extend Ember.SortableMixin,
  sortAscending: true
  init: ->
    @setProperties
      content: Ember.A()
    @_super()

PolyDiskDirectory = Ember.Object.extend
  relativePath: ''
  alternatives: null
  children: null
  init: ->
    @_super()
    @setProperties
      alternatives: SortedArray.create(sortProperties: ['id'])
      children: SortedArray.create(sortProperties: ['name'])

  nameOnDisk: Ember.computed -> # last element of relativePath
    comps = @get('relativePath').split(slash)
    comps[ comps.length - 1 ]
  .property('relativePath')

  nameBinding: 'alternatives.firstObject.name'


  getOrBuildChildByNameOnDisk: (nameOnDisk) ->
    children = @get('children')
    path = @get('relativePath')
    child = children.findProperty('nameOnDisk', nameOnDisk)
    unless child?
      child = PolyDiskDirectory.create
        relativePath: (if path.length is 0 then nameOnDisk else "#{path}/#{nameOnDisk}")
      children.addObject child
    child

  id: Ember.computed ->
    @get('alternatives').mapProperty('id').join(',')
  .property('alternatives.@each.id')


  hasSubDirs: Ember.computed ->
    @get('children.length') > 0 or @get('alternatives').anyBy('hasSubDirs')
  .property('alternatives.@each.hasSubDirs', 'children.length')

  exists: Ember.computed ->
    @get('alternatives').anyBy('exists')
  .property('alternatives.@each.exists')



window.PolyDiskDirectory = PolyDiskDirectory
