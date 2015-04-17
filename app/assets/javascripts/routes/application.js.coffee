Cataract.ApplicationRoute = Ember.Route.extend
  beforeModel: ->
    # just wait a bit for all the transitions to load
    if document.location.port is '80'
      Ember.run.next =>
        @send 'refreshTransfersAutomatically'
      , 5555

    # FIXME is this really needed with all the promises and needs?
    store = @get('store')
    @controllerFor('moves').set       'model', store.findAll('move')

    store.findAll('transfer').then (transfers)=>
      @controllerFor('transfers').set 'model', transfers
    , (jqxhr)=>
      @controllerFor('application').transfersError(jqxhr)

    store.find('setting', 'all').then (settings)=>
      @controllerFor('settings').set 'model', settings


      Ember.RSVP.hash
        disks:     store.findAll('disk')
        directories: store.findAll('directory')
        torrents: @get('torrents.finalContent')
      .then (loaded)=>
        @controllerFor('directories').set('directories', @get('store').filter('directory', -> true))
        @controllerFor('disks').set    'model', loaded.disks
        @get('torrents').gotoFirstPage()

  actions:
    save: (model)->
      model.save()
    rollback: (model)->
      model.rollback()
    refreshTransfers: ->
      if controller = @controllerFor('torrents')
        # TODO Spinner?
        controller.refreshTransfers()

    refreshTransfersAutomatically: ->
      @send 'refreshTransfers'
      Ember.run.next =>
        @send 'refreshTransfersAutomatically'
      , 5555

    openModal: (modalName, model) ->
      model = model.get('content') if model.isController
      @controllerFor(modalName).set "model", model
      @render modalName,
        into: "application"
        outlet: "modal"


    closeModal: ->
      @disconnectOutlet
        outlet: "modal"
        parentView: "application"

    createDirectoryFromDetected: (detected) ->
      detected.createDirectory()

    # where file is one of the dataTransfer.files of a drop event
    uploadTorrent: (file)->
      route = this
      reader = new FileReader()
      torrent = @get('store').createRecord('torrent')
      reader.onload = (upload) ->
        torrent.setProperties
          filedata: upload.target.result
          filename: file.name
          startAutomatically: true

        torrent.save().then (t)->
          route.transitionTo queryParams: { adding: false }
        , (error)->
          torrent.rollback()

      reader.readAsDataURL(file)
      true

    nextPage: ->
      controller = @controllerFor('torrents')
      if controller.get("hasNext")
        controller.incrementProperty "rangeStart", controller.get("rangeWindowSize")

    previousPage: ->
      controller = @controllerFor('torrents')
      if controller.get("hasPrevious")
        controller.decrementProperty "rangeStart", controller.get("rangeWindowSize")

    dragEnterDocument: ->
      app = @controllerFor('application')
      unless @get('adding')
        app.set '_previousAdding', false
        app.set 'adding', true
      app.set 'dragging', true
      false

    dragLeaveDocument: ->
      # keep the add box open, must close manually
      # else after drop on input[file] the modal box closes and clears the field
      app = @controllerFor('application')
      app.set 'dragging', false
      false

    startTorrent: (torrent) ->
      torrent = torrent.get('content') if torrent.isController
      transfer = @get('store').createRecord 'transfer',
        torrent: torrent
      transfer.save().then ->
        torrent.set 'status', 'running'
      false

    stopTorrent: (torrent) ->
      torrent = torrent.get('content') if torrent.isController
      torrent.get('transfer').then (transfer)->
        transfer.deleteRecord()
        transfer.save().then ->
          torrent.set 'status', 'archived'
      false
