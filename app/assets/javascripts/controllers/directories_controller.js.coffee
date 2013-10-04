# TODO merge with PolyDiskTree
Cataract.DirectoriesController = Ember.ArrayController.extend
  init: ->
    poly = PolyDiskTree.create()
    @setProperties
      poly: poly
      roots: poly.get('root.children')
    dirs = Cataract.Directory.find()
    # cannot bind Emu.ModelCollection to PolyDiskTree#directories, because it
    # creates blank records, serializing after Enumerable Observers are called
    dirs.on('didFinishLoading', ->
      poly.get('directories').pushObjects dirs.toArray()
    )
    @_super()
  currentBinding: 'Cataract.currentDirectory'
  diskBinding: 'Cataract.currentDisk'
  contentBinding: 'roots'
  # FIXME: isLoaded does not work on Arrays https://github.com/emberjs/data/issues/587
  isLoadedBinding: 'poly.directories.length'

  filterFunction: Ember.computed ->
    diskId = @get('disk.id')
    (record) ->
      record = record.record if record.record? # materialized or not?!
      want = true
      if diskId
        want &= record.get('diskId') is diskId
      want
  .property('unfilteredContent.@each.disk', 'disk')
