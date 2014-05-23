Cataract.Router.map ->
  @resource 'filter', path: 'filter/:status'
  @resource 'torrents'
  @route 'add', path: '/add'
  @resource 'torrent', path: '/torrent/:torrent_id'
  @resource 'directory', path: '/directory/:directory_id'
  @resource 'disk', path: 'disk/:disk_id'
  @route 'new_directory', path: 'directory/new'
  @route 'settings'
  @route 'treemap'

Cataract.ApplicationRoute = Ember.Route.extend
  beforeModel: ->
    # FIXME is this really needed with all the promises and needs?
    store = @get('store')
    @controllerFor('settings').set    'model',  store.find('setting', 'all')
    @controllerFor('transfers').set   'model', store.findAll('transfer')
    @controllerFor('disks').set       'model', store.findAll('disk')
    @controllerFor('moves').set       'model', store.findAll('move')
  actions:
    save: (model)->
      model.save()
    rollback: (model)->
      model.rollback()
    refreshTransfers: ->
      if controller = @controllerFor('torrents')
        # TODO Spinner?
        controller.refreshTransfers()
    openModal: (modalName, model) ->
      @controllerFor(modalName).set "model", model
      @render modalName,
        into: "application"
        outlet: "modal"


    closeModal: ->
      @disconnectOutlet
        outlet: "modal"
        parentView: "application"



Cataract.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'torrents', queryParams: { age: 'month', status: 'running' }

Cataract.FilterRoute = Ember.Route.extend
  beforeModel: (transition) ->
    @transitionTo 'torrents', queryParams: { age: 'month', status: transition.params.filter.status }

Cataract.TorrentsRoute = Ember.Route.extend
  queryParams:
    age:
      refreshModel: true
  beforeModel: (transition)->
    unless Ember.isNone( queryParams = transition.queryParams )
      if Ember.isNone(queryParams.age)
        queryParams.age = 'month'
      if Ember.isNone(queryParams.status)
        queryParams.status = 'recent'

      store = @get('store')
      # warmup store only when age has changed
      if queryParams.age != transition.params.queryParams?.age
        store.unloadAll('torrent')
        store.findQuery('torrent', age: queryParams.age)

  model: (params, transition) ->
    # TODO should we filter&paginate here already or on the controller?
    @get('store').filter 'torrent', (torrent)->
      # do not have to requery the server after deletion of torrent
      ! torrent.get('isDeleted')

  setupController: (controller, model) ->
    @_super(controller, model)
    controller.set 'unfilteredContent', model
    controller.gotoFirstPage()
    controller.refreshTransfers()
    @controllerFor('application').set('currentController', controller)

  renderTemplate: ->
    # we are always rendered
    # but the directory maybe, depends on query-params available later
    @render 'directory',
      controller: @controllerFor('directory')

Cataract.DetailedRoute = Ember.Route.extend
  setupController: (controller, model)->
    @_super(controller, model)
    @controllerFor('application').set 'detailsRouteActive', true
  deactivate: ->
    @_super()
    @controllerFor('application').set 'detailsRouteActive', false

# TODO have to think about these routes vs queryParams
Cataract.DirectoryRoute = Cataract.DetailedRoute.extend
  model: (params) ->
    @get('store').find 'directory', params.directory_id # FIXME ember should do this
  controllerName: 'directory'
  renderTemplate: ->
    @render 'directory'
  deactivate: (model)->
    @_super()
    @controllerFor('directory').set('content', null) # back to query-param

Cataract.TorrentRoute = Cataract.DetailedRoute.extend
  beforeModel: ->
    @controllerFor('torrents').get('unfilteredContent') # waiting for promise to resolve
  model: (params) ->
    @get('store').find 'torrent', params.torrent_id


Cataract.AddRoute = Ember.Route.extend
  controllerName: 'torrents_add'
  model: -> @get('store').createRecord('torrent')
  setupController: (controller, torrent) ->
    @_super(controller, torrent)
    @send 'openModal', 'create_torrent', torrent

Cataract.NewDirectoryRoute = Ember.Route.extend
  model: ->
    @get('store').createRecord 'directory',
      disk: @modelFor('disk')
      parentDirectory: @controllerFor('torrents').get('directory')
      virtual: false

  setupController: (controller, model) ->
    @_super(controller, model)
    @send 'openModal', 'create_directory', model

Cataract.DiskRoute = Cataract.DetailedRoute.extend()

Cataract.SettingsRoute = Cataract.DetailedRoute.extend
  model: ->
    @get('store').find('setting', 'all')
