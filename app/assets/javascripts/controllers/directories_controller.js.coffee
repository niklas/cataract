Cataract.DirectoriesController = Cataract.FilteredController.extend
  init: ->
    @set 'unfilteredContent', Cataract.Directory.find()
    @_super()
  currentBinding: 'Cataract.currentDirectory'
  diskBinding: 'Cataract.currentDisk'
  contentBinding: 'roots'
  # FIXME: isLoaded does not work on Arrays https://github.com/emberjs/data/issues/587
  isLoadedBinding: 'unfilteredContent.length'

  roots: Ember.computed ->
    @get('filteredContent').filter (record) ->
      !record.get('parentId')?
  .property('filteredContent', 'unfilteredContent.@each.parentId')

  filterFunction: Ember.computed ->
    disk = @get('disk')
    (record) ->
      record = record.record if record.record? # materialized or not?!
      want = true
      if disk
        want &= record.get('disk') is disk
      want
  .property('unfilteredContent.@each.disk', 'disk')
