Cataract.Spinner = Ember.View.extend
  classNames: 'spincontainer'
  didInsertElement: ->
    @$().spin()
  willDestroxElement: ->
    @$().spin(false)
  message: 'please wait...'

  template: Ember.Handlebars.compile "{{message}}"
