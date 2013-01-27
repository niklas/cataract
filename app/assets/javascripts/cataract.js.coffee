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
  olDinit: ->
    #@_super()
    # TODO put this into a view/controller combi
    jQuery(@get('rootElement')).ajaxError (e, jqxhr, settings, exception) ->
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

  currentDisk: null
  currentDirectory: null

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

Cataract.store = DS.Store.create
  revision: 11
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
  # TODO load on app initialization
  if jQuery( Cataract.get('rootElement') ).length > 9000
    Cataract.addObserver 'siteTitle', Cataract, (sender, key) -> $('head title').text("#{sender.get(key)} - Cataract")
    Cataract.set('siteTitle', 'loading')
    Cataract.set 'directories', Cataract.Directory.find()
    Cataract.set 'disks', Cataract.Disk.find()
    Cataract.set 'moves', Cataract.Move.find()
    Cataract.set 'transfers', Cataract.Transfer.find()
    Cataract.initialize()
    $('body').bind 'tick', -> Cataract.refreshTransfers(); true
    Cataract.Torrent.find()

