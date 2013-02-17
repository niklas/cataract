#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require_tree ./routes

#Ember.LOG_BINDINGS = true

Cataract = Ember.Application.create
  rootElement: 'body#ember'
  online: true
  offlineReason: null
  autoinit: false
  terms: ''
  ready: ->
    #@_super()
    # TODO put this into a view/controller combi
    jQuery(document).ajaxError (e, jqxhr, settings, exception) ->
      Cataract.set 'online', false
      if jqxhr.status == 502
        Cataract.set 'offlineReason', jqxhr.responseText
  refreshTransfers: ->
    # FIXME load differently, see BREAKING_CHANGES
    running = Cataract.store.filter Cataract.Torrent, (torrent) -> torrent.get('status') == 'running'
    $.getJSON "/transfers?running=#{running.mapProperty('id').join(',')}", (data, textStatus, xhr) ->
      for transfer in data.transfers
        Cataract.store.load Cataract.Transfer, transfer
      if data.torrents
        Cataract.store.loadMany Cataract.Torrent, data.torrents
      Cataract.set 'online', true
      true

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

DS.RESTAdapter.configure "plurals",
  directory: 'directories'

DS.RESTAdapter.configure 'Cataract.Torrent', sideloadAs: 'torrents'

Cataract.store = DS.Store.create
  revision: 11
  adapter: DS.RESTAdapter.create
    bulkCommit: false

window.Cataract = Cataract

