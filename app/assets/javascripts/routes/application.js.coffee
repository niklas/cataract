Cataract.ApplicationRoute = Ember.Route.extend
  beforeModel: ->
    # FIXME is this really needed with all the promises and needs?
    store = @get('store')
    @controllerFor('moves').set       'model', store.findAll('move')

    store.findAll('transfer').then (transfers)=>
      @controllerFor('transfers').set 'model', transfers
    , (jqxhr)=>
      @controllerFor('application').transfersError(jqxhr)

    Ember.RSVP.hash
      settings: store.find('setting', 'all')
      disks:     store.findAll('disk')
    .then (loaded)=>
      @controllerFor('settings').set 'model', loaded.settings
      @controllerFor('disks').set    'model', loaded.disks

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

    queryParamsDidChange: (changed, totalPresent, removed)->
      if changed.status || changed.age
        Ember.run.once =>
          @controllerFor('torrents').warmupStore()

      true

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
          route.transitionTo('torrent', t)
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
