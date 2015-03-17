Cataract.ApplicationRoute = Ember.Route.extend
  beforeModel: ->
    # FIXME is this really needed with all the promises and needs?
    store = @get('store')
    @controllerFor('settings').set    'model',  store.find('setting', 'all')
    @controllerFor('disks').set       'model', store.findAll('disk')
    @controllerFor('moves').set       'model', store.findAll('move')

    store.findAll('transfer').then (transfers)=>
      @controllerFor('transfers').set 'model', transfers
    , (jqxhr)=>
      @controllerFor('application').transfersError(jqxhr)

    true
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
