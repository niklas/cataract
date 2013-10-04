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
    Cataract.set 'torrentsController', @controllerFor('torrents')
    store = @get('store')
    @controllerFor('settings').set    'model',  store.find('setting', 'all')
    @controllerFor('transfers').set   'model', store.findAll('transfer')
    @controllerFor('disks').set       'model', store.findAll('disk')
    @controllerFor('moves').set       'model', store.findAll('move')
    # load the most recent torrents, for faster initial page load
    @controllerFor('torrents').reload()

Cataract.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'filter', 'running'

Cataract.FilterRoute = Ember.Route.extend
  activate: ->
    Cataract.set 'currentDirectory', null
    Cataract.set 'currentDisk', null

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
    ids = parseInt(i) for i in params.poly_id.split(',')
    @modelFor('directories').filter (d)->
      ids.any (id)->
        ids.indexOf(id) >= 0

  serialize: (model) ->
    { poly_id: model.mapProperty('id').join(',') }

  afterModel: (model)->
    curr = Cataract.get('currentDirectories')
    curr.clear()
    curr.pushObjects(model)
    if model.length == 1
      @transitionTo 'poly.directory', model, model.get('firstObject')
  deactivate: ->
    Cataract.get('currentDirectories').clear()


Cataract.PolyDirectoryRoute = Ember.Route.extend
  model: (params) ->
    @get('store').find 'directory', params.directory_id # FIXME ember should do this
  afterModel: (model)->
    Cataract.set 'currentDirectory', model
  deactivate: ->
    Cataract.set 'currentDirectory', null
  controllerName: 'directory'
  renderTemplate: ->
    @render 'directory'

Cataract.DiskRoute = Ember.Route.extend
  afterModel: (model) ->
    Cataract.set 'currentDisk', model

Cataract.TorrentRoute = Ember.Route.extend
  model: (params) ->
    @get('store').find 'torrent', params.torrent_id # FIXME ember should do this
  afterModel: (model) ->
    model.loadPayload()
    # Emu::Model.findQuery uses its own collection, resulting in two copies of
    # the same Torrent. We replace it with the newly loaded one
    # torrents = @controllerFor('torrents').get('unfilteredContent')
    # torrents.one 'didFinishLoading', ->
    #   copy = torrents.findProperty('id', model.get('id'))
    #   torrents.pushObject(model)
    #   torrents.removeObject(copy)

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
      parentDirectory: Cataract.get('currentDirectory')
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
