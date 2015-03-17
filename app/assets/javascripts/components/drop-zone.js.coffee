Cataract.DropZoneComponent = Ember.Component.extend
  elementId: 'dropzone'
  classNameBindings: ['hovered', 'inviting']

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
    @sendAction 'action', file for file in event.dataTransfer.files
    false


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
