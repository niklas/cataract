Cataract.FlashItemView = Ember.Rails.FlashItemView.extend
  alertClass: ( ->
    "alert-#{@get('content.severity')}"
  ).property('content.severity')
  template: Ember.Handlebars.compile """
  {{#with view.content}}
    <div {{bindAttr class="view.basicClassName severity view.alertClass"}}>{{message}}</div>
  {{/with}}
  """
Cataract.FlashListView = Ember.Rails.FlashListView.extend
  itemViewClass: Cataract.FlashItemView
