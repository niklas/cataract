slash = /\//

Cataract.SortedArray = Ember.ArrayProxy.extend Ember.SortableMixin,
  sortAscending: true
  content: Ember.computed ->
    Ember.A()

Cataract.PolyDiskDirectory = Ember.Object.extend
  relativePath: ''
  alternatives: Ember.computed ->
    Cataract.SortedArray.create(sortProperties: ['id'])

  hasMoreAlternatives: Ember.computed 'alternatives.length', ->
    ( @get('alternatives.length') || 0) > 1

  children: Ember.computed ->
    Cataract.SortedArray.create(sortProperties: ['name'])
  parent: null
  ancestorsAndSelf: Ember.computed ->
    list = [ this ]
    if parent = @get('parent')
      list.unshiftObjects parent.get('ancestorsAndSelf')
    list

  descendantsAndSelf: Ember.computed 'children.@each', ->
    list = [ this ]
    @get('children').mapProperty('descendantsAndSelf').forEach (descs)->
      list.pushObjects(descs)
    list

  # last element of relativePath
  nameOnDisk: Ember.computed 'relativePath', ->
    comps = @get('relativePath').split(slash)
    comps[ comps.length - 1 ]

  nameBinding: 'alternatives.firstObject.name'


  getOrBuildChildByNameOnDisk: (nameOnDisk) ->
    children = @get('children')
    path = @get('relativePath')
    child = children.findProperty('nameOnDisk', nameOnDisk)
    unless child?
      child = Cataract.PolyDiskDirectory.create
        relativePath: (if path.length is 0 then nameOnDisk else "#{path}/#{nameOnDisk}")
        parent: this
      children.addObject child
    child

  id: Ember.computed 'alternatives.@each.id', ->
    @get('alternatives').mapProperty('id').join(',')


  hasSubDirs: Ember.computed 'alternatives.@each.hasSubDirs', 'children.length', ->
    @get('children.length') > 0 or @get('alternatives').anyBy('hasSubDirs')

  exists: Ember.computed 'alternatives.@each.exists', ->
    @get('alternatives').anyBy('exists')


Cataract.PolyDiskDirectory.attr = (name)->
  Ember.computed name,
    get: ->
      @get "#{name}.poly"
    set: -> (key, value)->
      @set name, if value? then value.get('alternatives.firstObject') else value
