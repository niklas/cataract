Cataract.DragDetectorComponent = Ember.Component.extend
  leaveAction: 'dragDetectorLeaveAction'
  enterAction: 'dragDetectorEnterAction'
  stayDuration: 1000

  didInsertElement: ->
    @_bindToDragEvents()

  willDestroyElement: ->
    @_unbindToDragEvents()

  globalElement: Ember.computed -> document

  _bindToDragEvents: ->
    if @supportAjaxUploadProgressEvents() and not @isTouchDevice()
      self = this
      gel  = @get('globalElement')
      dur  = @get('stayDuration')
      isOver = false
      interval = undefined
      jQuery(gel).on "dragover", (e) ->
        e.preventDefault()
        clearInterval interval
        interval = setInterval(->
          isOver = false
          clearInterval interval
          self.sendAction 'leaveAction'
        , dur)
        unless isOver
          isOver = true
          self.sendAction 'enterAction'
    else
      @set('visible', false)

  _unbindToDragEvents: ->
    if @supportAjaxUploadProgressEvents() and not @isTouchDevice()
      gel  = @get('globalElement')
      jQuery(gel)
        .off('dragover')

  supportAjaxUploadProgressEvents: ->
    xhr = new XMLHttpRequest()
    !! (xhr? && ('upload' of xhr) && ('onprogress' of xhr.upload))

  isTouchDevice: ->
    !!('ontouchstart' of window)

