Cataract.DirectoriesController = Cataract.FilteredController.extend
  currentBinding: 'Cataract.currentDirectory'
  filterFunction: Ember.computed ->
    (record) ->
      record = record.record if record.record? # materialized or not?!

      record.get('parent') is null
  .property()
