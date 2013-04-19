Cataract.Router.map ->
  @resource 'filter', path: 'filter/:mode', ->
    @resource 'directory', path: 'directory/:directory_id'
  @resource 'torrent', path: 'torrent/:torrent_id'
  @resource 'directory', path: 'directory/:directory_id', ->
    @route 'edit', path: 'edit'
  @resource 'disk', path: 'disk/:disk_id'
  @route 'add_torrent', path: 'add'
  @route 'new_directory', path: 'directory/new'
  @route 'settings'

Cataract.ApplicationRoute = Ember.Route.extend
  setupController: ->
    Cataract.set 'settings', Cataract.Setting.find('all')
    @controllerFor('transfers').set   'model', Cataract.Transfer.find()
    @controllerFor('disks').set       'model', Cataract.Disk.find()
    @controllerFor('moves').set       'model', Cataract.Move.find()
    # load the most recent torrents, for faster initial page load
    @controllerFor('torrents').set    'unfilteredContent', Cataract.Torrent.find(per: 200, page: 1)

Cataract.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'filter', 'running'

Cataract.FilterRoute = Ember.Route.extend
  activate: ->
    Cataract.set 'currentDirectory', null
    Cataract.set 'currentDisk', null
    Cataract.set 'torrentsController', @controllerFor('torrents')

  model: (params) -> params.mode
  setupController: (controller, model) ->
    torrents = @controllerFor('torrents')
    torrents.set('mode', model)
    @controllerFor('application').set('currentController', torrents)

Cataract.DirectoryRoute = Ember.Route.extend
  setupController: (controller, model) ->
    @_super(controller, model)
    Cataract.set 'currentDirectory', model

Cataract.DiskRoute = Ember.Route.extend
  setupController: (controller, model) ->
    @_super(controller, model)
    Cataract.set 'currentDisk', model

Cataract.AddTorrentRoute = Ember.Route.extend
  model: ->
    Ember.Object.create()
  setupController: (controller, torrent) ->
    # TODO transition route back
    Cataract.AddTorrentModal.popup
      torrent: torrent
      directories: Cataract.Directory.find()
      disks: Cataract.Disk.find()

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
    # TODO transition route back
    Cataract.EditDirectoryModal.popup
      directory: model
      back: ['directory', model]

Cataract.SettingsRoute = Ember.Route.extend
  setupController: (controller, model) ->
    controller.set 'content', Cataract.get('settings')
