Ember.LOG_BINDINGS = true

Ember.Rails ?= Ember.Namespace.create()

Ember.Rails.FlashMessage = Ember.Object.extend
  severity: null
  message: ''

Ember.Rails.FlashItemView = Ember.View.extend
  basicClassName: 'flash'
  template: Ember.Handlebars.compile """
  {{#with view.content}}
    <div {{bindAttr class="view.basicClassName severity"}}>{{message}}</div>
  {{/with}}
  """

Ember.Rails.FlashListView = Ember.CollectionView.extend
  tagName: 'div'
  itemViewClass: Ember.Rails.FlashItemView
  didInsertElement: ->
    @$().ajaxComplete (event, request, settings) => @extractFlashFromHeaders request

  content: []

  extractFlashFromHeaders: (request)->
    headers = request.getAllResponseHeaders()
    for header in headers.split(/\n/)
      if m = header.match /^X-Flash-([^:]+)/
        @createMessage severity: m[1].underscore(), message: request.getResponseHeader("X-Flash-#{m[1]}")

  createMessage: (args) ->
    message = Ember.Rails.FlashMessage.create args
    @get('content').pushObject(message)

