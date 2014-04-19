Cataract.FilteredController = Ember.ArrayController.extend
  unfilteredContent: Ember.A()
  filteredContent:
    Ember.computed ->
      @get('unfilteredContent').filter( @get('filterFunction') )
    .property('filterFunction', 'unfilteredContent.@each.id', 'unfilteredContent.@each.status', 'unfilteredContent.@each')
  # TODO _add_ property dependencies in subclass

  filterFunction:
    Ember.computed ->
      (record) ->
        true
    .property()

