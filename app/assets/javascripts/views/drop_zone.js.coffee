Cataract.DropZoneView = Ember.View.extend
  elementId: 'dropzone'
  classNameBindings: ['hovered', 'inviting']
  template: Ember.Handlebars.compile '<i class="glyphicon glyphicon-upload"></i> <div class="inflate"></div>'
  hovered: false
  inviting: false

  supportAjaxUploadProgressEvents: ->
    xhr = new XMLHttpRequest()
    !! (xhr? && ('upload' of xhr) && ('onprogress' of xhr.upload))

  isTouchDevice: ->
    !!('ontouchstart' of window)

  drop: (event) ->
    event.preventDefault()
    @set 'hovered', false
    @set 'inviting', false
    @upload file for file in event.dataTransfer.files
    false

  upload: (file) ->
    reader = new FileReader()
    controller = @get('controller')
    torrent = controller.get('store').createRecord('torrent')
    reader.onload = (upload) ->
      torrent.setProperties
        filedata: upload.target.result
        filename: file.name
        startAutomatically: true

      torrent.save().then (t)->
        controller.transitionToRoute('torrent', t)
      , (error)->
        torrent.rollback()

    reader.readAsDataURL(file)

  dragOver: (e) ->
    e.preventDefault()
    unless @get('hovered')
      @set 'hovered', true

  dragLeave: (e) ->
    e.preventDefault()
    @set 'hovered', false

  docEnter: (e) ->
    e.preventDefault()
    console?.debug 'docEnter'
    unless @get('inviting')
      @set 'inviting', true
    false

  docLeave: (e) ->
    console?.debug "docLeave"
    @set 'inviting', false



  didInsertElement: ->
    dropzone = this
    if @supportAjaxUploadProgressEvents() and not @isTouchDevice()
      isOver = false
      interval = undefined
      $(document).on "dragover", (e) ->
        e.preventDefault()
        clearInterval interval
        interval = setInterval(->
          isOver = false
          clearInterval interval
          dropzone.docLeave(e)
        , 1000)
        unless isOver
          isOver = true
          dropzone.docEnter(e)
    else
      @set('visible', false)

  willDestroyElement: ->
    jQuery(document)
      .off('dragover')

