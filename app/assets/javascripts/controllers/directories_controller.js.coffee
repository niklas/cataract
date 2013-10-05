# TODO merge with PolyDiskTree
Cataract.DirectoriesController = Ember.ArrayController.extend
  init: ->
    poly = @get('poly')
    @get('store').findAll('directory').then (dirs)->
      poly.get('directories').pushObjects dirs.toArray()
    @_super()
  poly: Ember.computed ->
    PolyDiskTree.create()
  .property()
  needs: ['torrents']
  rootsBinding: 'poly.root.children'
  currentBinding: 'controllers.torrents.directory'
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
