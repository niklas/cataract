#= require_tree ./lib
#= require_self
#= require_tree ./addons
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require_tree ./routes

#Ember.LOG_BINDINGS = true
Ember.FEATURES['query-params'] = yes

CataractApplication = Ember.Application.extend
  rootElement: '#ember'
  online: false # wait for first refreshTransfers
  offlineReason: 'loading...'
  autoinit: false
  terms: ''
  transfers: Ember.A()
  ready: ->
    #@_super()
    # FIXME load transfer through controller needs?
    # @set 'transfers', @get('store').findAll('transfer')
    # TODO put this into a view/controller combi
    jQuery(document).ajaxError (e, jqxhr, settings, exception) ->
      Cataract.set 'online', false
      if jqxhr.status == 502
        Cataract.set 'offlineReason', jqxhr.responseText

  # TODO move to diskcontroller?
  currentDisk: null

Cataract = CataractApplication.create()

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

Cataract.ApplicationAdapter = DS.RailsRESTAdapter.extend()
#DS.RESTAdapter.configure "plurals",
#  directory: 'directories'
#  detected_directory: 'detected_directories'
#
#DS.RESTAdapter.configure 'Cataract.Torrent', sideloadAs: 'torrents'

window.Cataract = Cataract

if console?
  Ember.RSVP.configure 'onerror', (e)->
    console.log "error in promise", e.message, e.stack
