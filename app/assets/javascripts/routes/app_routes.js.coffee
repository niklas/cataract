Cataract.Router.map ->
  @resource 'filter', path: 'filter/:mode'
  @resource 'torrent', path: 'torrent/:torrent_id'
  @resource 'poly', path: 'poly/:poly_id', ->
    @resource 'poly.directory', path: 'directory/:directory_id'
  @route 'edit_directory', path: 'directory/:directory_id/edit'
  @resource 'disk', path: 'disk/:disk_id'
  @route 'add_torrent', path: 'add'
  @route 'new_directory', path: 'directory/new'
  @route 'settings'

Cataract.ApplicationRoute = Ember.Route.extend
  beforeModel: ->
    # FIXME is this really needed with all the promises?
    store = @get('store')
    @controllerFor('settings').set    'model',  store.find('setting', 'all')
    @controllerFor('transfers').set   'model', store.findAll('transfer')
    @controllerFor('disks').set       'model', store.findAll('disk')
    #@controllerFor('moves').set       'model', store.findAll('move')
    # OPTIMIZE load the most recent torrents, for faster initial page load
    @controllerFor('torrents').reload()

Cataract.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'filter', 'running'

Cataract.FilterRoute = Ember.Route.extend
  model: (params) -> params.mode
  setupController: (controller, model) ->
    torrents = @controllerFor('torrents')
    torrents.set('mode', model)
    torrents.refreshTransfers()
    @controllerFor('application').set('currentController', torrents)
  deactivate: ->
    torrents = @controllerFor('torrents')
    torrents.set('mode', null)

Cataract.PolyRoute = Ember.Route.extend
  model: (params) ->
    ids = (i for i in params.poly_id.split(','))
    @controllerFor('directories').get('poly.directories').filter (d)->
      ids.indexOf(d.get('id')) >= 0

  serialize: (model) ->
    { poly_id: model.mapProperty('id').join(',') }

  afterModel: (model)->
    curr = @controllerFor('torrents').get('directories')
    curr.clear()
    curr.pushObjects(model)
    if model.length == 1
      @transitionTo 'poly.directory', model, model.get('firstObject')
  deactivate: ->
    @controllerFor('torrents').get('directories').clear()


Cataract.PolyDirectoryRoute = Ember.Route.extend
  model: (params) ->
    @get('store').find 'directory', params.directory_id # FIXME ember should do this
  afterModel: (model)->
    @controllerFor('torrents').set('directory', model)
  deactivate: ->
    @controllerFor('torrents').set('directory', null)
  controllerName: 'directory'
  renderTemplate: ->
    @render 'directory'

Cataract.DiskRoute = Ember.Route.extend
  afterModel: (model) ->
    Cataract.set 'currentDisk', model

Cataract.TorrentRoute = Ember.Route.extend
  model: (params) ->
    @controllerFor('torrents').get('unfilteredContent').findProperty('id', params.torrent_id)

Cataract.AddTorrentRoute = Ember.Route.extend
  model: ->
    Cataract.Torrent.createRecord()
  setupController: (controller, torrent) ->
    controller.set 'content', torrent # Ember actually should do this for us # it does in _super
    router = this
    store = @get('store')
    controller.setDefaultDirectory()
    # TODO transition route "back" (must remember last route?)
    Cataract.AddTorrentModal.popup
      torrent: torrent
      directories: store.findAll('directory')
      disks: store.findAll('disk')
      callback: (opts) ->
        if opts.primary
          torrent.setProperties
            fetchAutomatically: true
            startAutomatically: true
          torrent.one 'didFinishSaving', ->
            router.controllerFor('torrents').didAddRunningTorrent(torrent)
          torrent.save()
        true

Cataract.NewDirectoryRoute = Ember.Route.extend
  model: ->
    Cataract.Directory.createRecord
      disk: Cataract.get('currentDisk')
      parentDirectory: @controllerFor('torrents').get('directory')
      virtual: false

  setupController: (controller, model) ->
    # TODO transition route back
    Cataract.NewDirectoryModal.popup
      directory: model
      directories: model.get('disk.directories')
      disks: @get('store').findAll('disk')

  renderTemplate: ->

Cataract.EditDirectoryRoute = Ember.Route.extend
  model: (params) ->
    @modelFor 'directory'
  setupController: (controller, model) ->
    model.prepareUndo('filter', 'subscribed')
    # TODO transition route back
    Cataract.EditDirectoryModal.popup
      directory: model
      back: ['poly.directory', model.get('poly.alternatives'), model]

Cataract.SettingsRoute = Ember.Route.extend
  model: ->
    @get('store').find('setting', 'all')
