Cataract.DropZoneView = Ember.View.extend
  elementId: 'dropzone'
  classNameBindings: ['hovered', 'inviting']
  template: Ember.Handlebars.compile ''
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
    torrent = Cataract.Torrent.createRecord()
    torrent.one 'didFinishSaving', ->
      Cataract.get('torrentsController')?.didAddRunningTorrent(torrent)
    reader.onload = (upload) ->
      torrent.setProperties
        filedata: upload.target.result
        filename: file.name
        startAutomatically: true
      torrent.save()
    reader.readAsDataURL(file)

  dragOver: (e) ->
    e.preventDefault()
    unless @get('hovered')
      @set 'hovered', true

  dragLeave: (e) ->
    e.preventDefault()
    @set 'hovered', false

  docOver: (e) ->
    e.preventDefault()
    unless @get('inviting')
      @set 'inviting', true
    false

  docLeave: (e) ->
    console.debug "leaving doc"
    @set 'inviting', false



  didInsertElement: ->
    dropzone = this
    if @supportAjaxUploadProgressEvents() and not @isTouchDevice()
      jQuery(document)  # I am too stupid for .apply
        .bind('dragover', (e) -> dropzone.docOver(e) )
        .bind('dragleave', (e) -> dropzone.docLeave(e) )
    else
      @set('visible', false)

  willDestroyElement: ->
    jQuery(document)
      .unbind('dragover')
      .unbind('dragleave')

