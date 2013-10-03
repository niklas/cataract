Cataract.Router.map ->
  @resource 'filter', path: 'filter/:mode'
  @resource 'torrent', path: 'torrent/:torrent_id'
  @resource 'poly', path: 'poly/:poly_id', ->
    @resource 'poly.directory', path: 'directory/:directory_id'
  #@resource 'directory', path: 'directory/:directory_id', ->
  #  @route 'edit', path: 'edit'
  @resource 'disk', path: 'disk/:disk_id'
  @route 'add_torrent', path: 'add'
  @route 'new_directory', path: 'directory/new'
  @route 'settings'

Cataract.ApplicationRoute = Ember.Route.extend
  beforeModel: ->
    Cataract.set 'torrentsController', @controllerFor('torrents')
    @controllerFor('settings').set    'model',  Cataract.Setting.find('all')
    @controllerFor('transfers').set   'model', Cataract.Transfer.find()
    @controllerFor('disks').set       'model', Cataract.Disk.find()
    @controllerFor('moves').set       'model', Cataract.Move.find()
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
    Cataract.Directory.find(parseInt(i)) for i in params.poly_id.split(',')
    # FIXME we want a promise here, filtering ctrl.directories by ids

  serialize: (model) ->
    { poly_id: model.mapProperty('id').join(',') }

  afterModel: (model)->
    curr = Cataract.get('currentDirectories')
    curr.clear()
    curr.pushObjects(model)
  deactivate: ->
    Cataract.get('currentDirectories').clear()


Cataract.PolyDirectoryRoute = Ember.Route.extend
  afterModel: (model)->
    Cataract.set 'currentDirectory', model
  deactivate: ->
    Cataract.set 'currentDirectory', null

Cataract.DiskRoute = Ember.Route.extend
  setupController: (controller, model) ->
    @_super(controller, model)
    Cataract.set 'currentDisk', model

Cataract.TorrentRoute = Ember.Route.extend
  model: (params) ->
    Cataract.Torrent.find params.torrent_id # FIXME ember should do this
  afterModel: (model) ->
    model.loadPayload()
    # Emu::Model.findQuery uses its own collection, resulting in two copies of
    # the same Torrent. We replace it with the newly loaded one
    torrents = @controllerFor('torrents').get('unfilteredContent')
    torrents.one 'didFinishLoading', ->
      copy = torrents.findProperty('id', model.get('id'))
      torrents.pushObject(model)
      torrents.removeObject(copy)

Cataract.AddTorrentRoute = Ember.Route.extend
  model: ->
    Cataract.Torrent.createRecord()
  setupController: (controller, torrent) ->
    controller.set 'content', torrent # Ember actually should do this for us
    router = this
    controller.setDefaultDirectory()
    # TODO transition route "back" (must remember last route?)
    Cataract.AddTorrentModal.popup
      torrent: torrent
      directories: Cataract.Directory.find()
      disks: Cataract.Disk.find()
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
      parent: Cataract.get('currentDirectory')
      virtual: false

  setupController: (controller, model) ->
    # TODO transition route back
    Cataract.NewDirectoryModal.popup
      directory: model
      directories: model.get('disk.directories')
      disks: Cataract.Disk.find()

  renderTemplate: ->

Cataract.DirectoryEditRoute = Ember.Route.extend
  model: (params) ->
    @modelFor 'directory'
  setupController: (controller, model) ->
    model.prepareUndo('filter', 'subscribed')
    # TODO transition route back
    Cataract.EditDirectoryModal.popup
      directory: model
      back: ['directory', model]

Cataract.SettingsRoute = Ember.Route.extend
  model: ->
    Cataract.Setting.find('all')
