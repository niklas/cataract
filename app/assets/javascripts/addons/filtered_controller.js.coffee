Cataract.FilteredController = Ember.ArrayController.extend
  unfilteredContent: Ember.A()
  filteredContent: Ember.computed ->
    @get('unfilteredContent').filter( @get('filterFunction') )
  .property('filterFunction', 'unfilteredContent.@each.id')

  filterFunction: Ember.computed ->
    (record) ->
      true
  .property()

