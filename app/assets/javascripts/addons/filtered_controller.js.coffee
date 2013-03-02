Cataract.FilteredController = Ember.ArrayController.extend
  filtered: Ember.computed ->
    @get('content').filter( @get('filterFunction') )
  .property('filterFunction', 'content.@each.id')

  filterFunction: Ember.computed ->
    (record) ->
      true
  .property()

