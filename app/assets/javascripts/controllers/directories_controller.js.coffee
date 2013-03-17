Cataract.DirectoriesController = Cataract.FilteredController.extend
  currentBinding: 'Cataract.currentDirectory'
  diskBinding: 'Cataract.currentDisk'
  contentBinding: 'roots'
  unfilteredContent: Cataract.Directory.find()
  # FIXME: isLoaded does not work on Arrays https://github.com/emberjs/data/issues/587
  isLoadedBinding: 'unfilteredContent.length'

  roots: Ember.computed ->
    @get('filteredContent').filter (record) ->
      record.get('parent') is null
  .property('filteredContent', 'unfilteredContent.@each.parent')

  filterFunction: Ember.computed ->
    disk = @get('disk')
    (record) ->
      record = record.record if record.record? # materialized or not?!
      want = true
      if disk
        want &= record.get('disk') is disk
      want
  .property('unfilteredContent.@each.disk', 'disk')
