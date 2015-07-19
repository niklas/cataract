#= require_self
#= require ./lib/poly_disk_directory
#= require ./lib/quantify
#= require_tree ./adapters
#= require_tree ./mixins
#= require_tree ./initializers
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./components
#= require_tree ./templates
#= require_tree ./routes
#= require ./router

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

window.Cataract = Cataract

if console?
  Ember.RSVP.configure 'onerror', (e)->
    console.log "error in promise", e.message, e.stack
