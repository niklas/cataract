# TODO make this a real (TM) component
# may require re-factoring of ember-rails-flash gem
Cataract.FlashItemView = Ember.Rails.FlashItemView.extend
  classNameBindings: ['basicClassName', 'alertClass']
  alertClass:
    Ember.computed ->
      "alert alert-#{@get('content.severity')}"
    .property('content.severity')
  delay: 23 * 1000
  fadeDuration: 1000
  templateName: 'flash-item'

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

Cataract.FlashListComponent = Ember.Rails.FlashListView.extend
  elementId: 'ember-flash'
  itemViewClass: Cataract.FlashItemView
