#= require_tree ./lib
#= require_self
#= require_tree ./cataract
#= require_tree ./initializers
#= require_tree ./addons
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require_tree ./routes
#= require_tree ./components

CataractApplication = Ember.Application.extend
  rootElement: '#ember'
  autoinit: false
  terms: ''
  transfers: Ember.A()

  # TODO move to diskcontroller?
  currentDisk: null


Cataract = CataractApplication.create
  LOG_TRANSITIONS: false
  LOG_TRANSITIONS_INTERNAL: false

  # TODO move into DirectoriesController
  # rootDirectories: (->
  #   Cataract.store.filter Cataract.Directory, (dir) ->
  #     want = true
  #     dir = dir.record if dir.record?
  #     if currentDisk = Cataract.get('currentDisk')
  #       want = want and dir.get('disk') is currentDisk
  #     want = want and not dir.get('parentId')?
  #     want
  # ).property('directories.@each.parentId', 'currentDisk')

jQuery.ajaxSetup
  dataType: 'json'

DS.RailsRESTSerializer = DS.ActiveModelSerializer.extend()
DS.RailsRESTAdapter = DS.ActiveModelAdapter.extend
  defaultSerializer: 'DS/railsREST'

Cataract.ApplicationAdapter = DS.RailsRESTAdapter.extend
  ajaxError: (jqxhr)->
    #@_super(jqxhr)
    if jqxhr and jqxhr.status is 500
      Ember.Rails.flashMessages.createMessage
        severity: 'error'
        message: jqxhr.responseJSON.error
      # stop propagating
      false
#DS.RESTAdapter.configure "plurals",
#  directory: 'directories'
#  detected_directory: 'detected_directories'
#
#DS.RESTAdapter.configure 'Cataract.Torrent', sideloadAs: 'torrents'

window.Cataract = Cataract

if console?
  Ember.RSVP.configure 'onerror', (e)->
    console.log "error in promise", e.message, e.stack
