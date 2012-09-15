#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require_tree ./routes

#Ember.LOG_BINDINGS = true

Cataract = Ember.Application.create
  rootElement: '#container'
  transferLoaded: false
  refreshTransfers: ->
    running = Cataract.store.filter Cataract.Torrent, (torrent) -> torrent.get('isRunning')
    $.getJSON "/progress?running=#{running.mapProperty('id').join(',')}", (data, textStatus, xhr) ->
      Cataract.store.loadMany Cataract.Transfer, data.transfers
      Cataract.set 'transferLoaded', true
      true

Cataract.store = DS.Store.create
  revision: 4
  adapter: DS.RESTAdapter.create
    bulkCommit: false
    plurals:
      directory: 'directories'


window.Cataract = Cataract

jQuery ->
  Cataract.addObserver 'siteTitle', Cataract, (sender, key) -> $('head title').text("#{sender.get(key)} - Cataract")
  Cataract.set('siteTitle', 'loading')
  Cataract.initialize()
  $('body').bind 'tick', -> Cataract.refreshTransfers(); true
  Cataract.Torrent.find()

