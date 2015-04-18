Cataract.ScrollDetectorComponent = Ember.Component.extend

  bindToScroll: (->
    Ember.$(document).on 'scroll', =>
      Ember.run.debounce this, @didScroll, 100
  ).on('didInsertElement')

  didScroll: ->
    console?.debug 'scrolled'
    @sendAction('action', $(document).scrollTop())

