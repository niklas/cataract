Cataract.Router.map ->
  @resource 'filter', path: 'filter/:status'
  @resource 'torrents', queryParams: ['status', 'age', 'directories'], ->
    @resource 'torrent', path: '/:torrent_id'
  @resource 'poly', path: 'poly/:poly_id', ->
    @resource 'poly.directory', path: 'directory/:directory_id'
  @route 'edit_directory', path: 'directory/:directory_id/edit'
  @resource 'disk', path: 'disk/:disk_id'
  @route 'add_torrent', path: 'add'
  @route 'new_directory', path: 'directory/new'
  @route 'settings'

Cataract.ApplicationRoute = Ember.Route.extend
  beforeModel: ->
    # FIXME is this really needed with all the promises and needs?
    store = @get('store')
    @controllerFor('settings').set    'model',  store.find('setting', 'all')
    @controllerFor('transfers').set   'model', store.findAll('transfer')
    @controllerFor('disks').set       'model', store.findAll('disk')
    @controllerFor('moves').set       'model', store.findAll('move')

Cataract.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'torrents', queryParams: { age: 'month', status: 'running' }

Cataract.FilterRoute = Ember.Route.extend
  beforeModel: (transition) ->
    @transitionTo 'torrents', queryParams: { age: 'month', status: transition.params.status }

Cataract.TorrentsRoute = Ember.Route.extend
  beforeModel: (queryParams)->
    if Ember.isNone(queryParams.age)
      throw "need age queryParam"


  model: (params, queryParams, transition) ->
    store = @get('store')
    # warmup store by site-loading
    store.findQuery('torrent', age: queryParams.age)
    # TODO should we filter&paginate here already or on the controller?
    store.filter 'torrent', (torrent)->
      # do not have to requery the server after deletion of torrent
      ! torrent.get('isDeleted')

  setupController: (controller, model, queryParams) ->
    @setupDirectories(controller, queryParams)
    controller.set 'unfilteredContent', model
    controller.set('mode', queryParams.status)
    controller.gotoFirstPage()
    controller.refreshTransfers()
    @controllerFor('application').set('currentController', controller)

  setupDirectories: (controller, queryParams)->
    unless Ember.isNone(list=queryParams.directories)
      ids = (i for i in list.split(','))
      controller.set 'directories', @controllerFor('directories')
        .get('poly.directories')
        .filter (d)->
          ids.indexOf(d.get('id')) >= 0

  renderTemplate: -> # nothing, always present in application.handlebars
    @render 'torrents/tabs',
      outlet: 'pre',
      controller: @controllerFor('torrents')
    @render 'torrents/navigation',
      outlet: 'nav',
      controller: @controllerFor('torrents')

Cataract.PolyRoute = Ember.Route.extend
  model: (params) ->

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
  beforeModel: ->
    @controllerFor('torrents').get('unfilteredContent') # waiting for promise to resolve
  model: (params) ->
    @get('store').find 'torrent', params.torrent_id

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
