Ember.Rails ?= Ember.Namespace.create()

Ember.Rails.FlashMessage = Ember.Object.extend
  severity: null
  message: ''

Ember.Rails.FlashListController = Ember.ArrayController.extend
  content: []

  extractFlashFromHeaders: (request)->
    headers = request.getAllResponseHeaders()
    for header in headers.split(/\n/)
      if m = header.match /^X-Flash-([^:]+)/
        message = Ember.Rails.FlashMessage.create severity: m[1].underscore(), message: request.getResponseHeader("X-Flash-#{m[1]}")
        @get('content').pushObject(message)

Ember.Rails.FlashListView = Ember.View.extend
  basicClassName: 'flash'
  template: Ember.Handlebars.compile """
    {{#each flash in controller}}
    <div {{bindAttr class="view.basicClassName flash.severity"}}>{{flash.message}}</div>
    {{/each}}
  """
  didInsertElement: ->
    @$().ajaxComplete (event, request, settings) =>
      @get('controller').extractFlashFromHeaders request

  controller: Ember.Rails.FlashListController.create()
