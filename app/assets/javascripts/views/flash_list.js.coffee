Cataract.FlashItemView = Ember.Rails.FlashItemView.extend
  classNameBindings: ['basicClassName', 'alertClass']
  alertClass: Ember.computed ->
    "alert alert-#{@get('content.severity')}"
  .property('content.severity')
  delay: 23 * 1000
  fadeDuration: 3 * 1000
  template: Ember.Handlebars.compile """
  {{#with view.content}}
    <a class="close" {{action "closeQuickly" target=view}}> ×</a>
    {{message}}
  {{/with}}
  """

  closeQuickly: ->
    @set 'fadeDuration', @get('fadeDuration') / 3
    @close()

  close: ->
    @stopTimeout()
    flash = @get('content')
    @$().fadeOut @get('fadeDuration'), ->
      flash.destroy()
      Ember.Rails.get('flashMessages').removeObject(flash)

  startTimeout: ->
    @set 'timeout', setTimeout( (view) ->
      view.close()
    , @get('delay'), this
    )

  stopTimeout: ->
    timeout = @get('timeout')
    if timeout
      clearTimeout timeout
      @set('timeout', null)

  didInsertElement: ->
    @startTimeout()

  mouseEnter: ->
    @stopTimeout()
    true

  mouseLeave: ->
    @startTimeout()
    true

Cataract.FlashListView = Ember.Rails.FlashListView.extend
  elementId: 'ember-flash'
  itemViewClass: Cataract.FlashItemView
