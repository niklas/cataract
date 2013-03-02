Cataract.FlashItemView = Ember.Rails.FlashItemView.extend
  classNameBindings: ['basicClassName', 'alertClass']
  alertClass: Ember.computed ->
    "alert alert-#{@get('content.severity')}"
  .property('content.severity')
  template: Ember.Handlebars.compile """
  {{#with view.content}}
    {{message}}
    <a class="close" {{action "close" target=view}}> ×</a>
  {{/with}}
  """
  close: ->
    flash = @get('content')
    flash.destroy()
    Ember.Rails.get('flashMessages').removeObject(flash)

Cataract.FlashListView = Ember.Rails.FlashListView.extend
  elementId: 'ember-flash'
  itemViewClass: Cataract.FlashItemView
