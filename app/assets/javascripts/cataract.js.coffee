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
  transferLoaded: false
  online: true
  offlineReason: null
  init: ->
    @_super()
    jQuery(@get('rootElement')).ajaxError (e, jqxhr, settings, exception) ->
      Cataract.set 'online', false
      if jqxhr.status == 502
        Cataract.set 'offlineReason', jqxhr.responseText
  refreshTransfers: ->
    running = Cataract.store.filter Cataract.Torrent, (torrent) -> torrent.get('record.isRunning')
    $.getJSON "/transfers?running=#{running.mapProperty('id').join(',')}", (data, textStatus, xhr) ->
      for transfer in data.transfers
        unless transfer.up_rate is null and transfer.down_rate is null # torrent stopped from somewhere else
          Cataract.store.load Cataract.Transfer, transfer
      if data.torrents
        Cataract.store.loadMany Cataract.Torrent, data.torrents
      Cataract.set 'transferLoaded', true
      Cataract.set 'online', true
      true

  rootDirectories: (->
    Cataract.store.filter Cataract.Directory, (dir) ->
      dir = dir.record if dir.record?
      !dir.get('parentId')?
  ).property('directories.@each.parentId')

Cataract.store = DS.Store.create
  revision: 4
  adapter: DS.RESTAdapter.create
    bulkCommit: false
    plurals:
      directory: 'directories'
    mappings:
      transfer: 'Cataract.Transfer'
      torrent: 'Cataract.Torrent'
      torrents: 'Cataract.Torrent'
      move: 'Cataract.Move'
      disk: 'Cataract.Disk'
      directory: 'Cataract.Directory'


window.Cataract = Cataract

jQuery ->
  if jQuery( Cataract.get('rootElement') ).length > 0
    Cataract.addObserver 'siteTitle', Cataract, (sender, key) -> $('head title').text("#{sender.get(key)} - Cataract")
    Cataract.set('siteTitle', 'loading')
    Cataract.set 'directories', Cataract.Directory.find()
    Cataract.set 'disks', Cataract.Disk.find()
    Cataract.set 'moves', Cataract.Move.find()
    Cataract.initialize()
    $('body').bind 'tick', -> Cataract.refreshTransfers(); true
    Cataract.Torrent.find()

