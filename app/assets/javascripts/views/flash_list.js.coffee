Cataract.FlashItemView = Ember.Rails.FlashItemView.extend
  classNameBindings: ['basicClassName', 'alertClass']
  alertClass: Ember.computed ->
    "alert alert-#{@get('content.severity')}"
  .property('content.severity')
  template: Ember.Handlebars.compile """
  {{#with view.content}}
    {{message}}
  {{/with}}
  """

Cataract.FlashListView = Ember.Rails.FlashListView.extend
  elementId: 'ember-flash'
  itemViewClass: Cataract.FlashItemView
