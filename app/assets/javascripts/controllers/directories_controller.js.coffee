Cataract.DirectoriesController = Cataract.FilteredController.extend
  currentBinding: 'Cataract.currentDirectory'
  diskBinding: 'Cataract.currentDisk'
  contentBinding: 'filteredContent'
  unfilteredContent: Cataract.Directory.find()
  filterFunction: Ember.computed ->
    disk = @get('disk')
    (record) ->
      record = record.record if record.record? # materialized or not?!
      want = true
      want &= record.get('parent') is null
      if disk
        want &= record.get('disk') is disk
      want
  .property('unfilteredContent.@each.parent', 'disk')
