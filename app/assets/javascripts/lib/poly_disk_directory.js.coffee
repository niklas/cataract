slash = /\//

SortedArray = Ember.ArrayProxy.extend Ember.SortableMixin,
  sortAscending: true
  content:
    Ember.computed ->
      Ember.A()
    .property()

PolyDiskDirectory = Ember.Object.extend
  relativePath: ''
  alternatives:
    Ember.computed ->
      SortedArray.create(sortProperties: ['id'])
    .property()
  children:
    Ember.computed ->
      SortedArray.create(sortProperties: ['name'])
    .property()
  parent: null
  ancestorsAndSelf:
    Ember.computed ->
      list = [ this ]
      if parent = @get('parent')
        list.unshiftObjects parent.get('ancestorsAndSelf')
      list
    .property('parent')

  descendantsAndSelf:
    Ember.computed ->
      list = [ this ]
      @get('children').mapProperty('descendantsAndSelf').forEach (descs)->
        list.pushObjects(descs)
      list
    .property('children.@each')

  nameOnDisk:
    Ember.computed -> # last element of relativePath
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
        parent: this
      children.addObject child
    child

  id:
    Ember.computed ->
      @get('alternatives').mapProperty('id').join(',')
    .property('alternatives.@each.id')


  hasSubDirs:
    Ember.computed ->
      @get('children.length') > 0 or @get('alternatives').anyBy('hasSubDirs')
    .property('alternatives.@each.hasSubDirs', 'children.length')

  exists:
    Ember.computed ->
      @get('alternatives').anyBy('exists')
    .property('alternatives.@each.exists')


PolyDiskDirectory.attr = (name)->
  Ember.computed (key, value)->
    if arguments.length > 1
      @set name, if value? then value.get('alternatives.firstObject') else value
    @get "#{name}.poly"
  .property(name)


window.PolyDiskDirectory = PolyDiskDirectory
