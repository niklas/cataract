#= require application
#= require_tree ./

TEST = {}
TEST.stubLinkToHelper = ->
  TEST.originalLinkToHelper = Ember.Handlebars.helpers["link-to"]  unless TEST.originalLinkToHelper
  Ember.Handlebars.helpers["link-to"] = (route) ->
    options = [].slice.call(arguments, -1)[0]
    Ember.Handlebars.helpers.view.call this, Em.View.extend(
      tagName: "a"
      attributeBindings: ["href"]
      href: route
    ), options

  return

TEST.restoreLinkToHelper = ->
  Ember.Handlebars.helpers["link-to"] = TEST.originalLinkToHelper
  TEST.originalLinkToHelper = null

window.TEST = TEST
