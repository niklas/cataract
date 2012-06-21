#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require bootstrap
#= require jquery.sausage
#= require endless_page
#= require spinner
#= require jquery-filedrop/jquery.filedrop
#= require radio_buttons
#= require bindWithDelay

jQuery ->
  $('#torrent_search').endlessSearch()

  search = ->
    $(@).closest('form')
      .find('input.page').val(1).end()
      .submit()

  $('form#new_torrent_search :radio').bind 'change', search
  $('form#new_torrent_search :text').bindWithDelay 'keyup change', search, 333


  $('#title').bind 'click', -> $('body').trigger 'tick'

  $('body').bind 'tick', ->
    active = $('section.transfer').attr('id')
    if active?
      $.getScript '/torrents/' + active.replace(/^\D+/, '')
    else
      $.getScript '/torrents/progress'
    true

  $('form#edit').hide().each ->
    $form = $(this)
    $('a.edit').click -> $form.toggle('slow')

  setInterval ->
    $('body').trigger 'tick'
  , 23 * 1000

  supportAjaxUploadProgressEvents = ->
    xhr = new XMLHttpRequest()
    !! (xhr? && ('upload' of xhr) && ('onprogress' of xhr.upload))

  isTouchDevice = ->
    !!('ontouchstart' of window)

  $('#dropzone').each ->
    if supportAjaxUploadProgressEvents() and not isTouchDevice()
      $dropzone = $(this).show()
      $dropzone.filedrop
        url: $dropzone.data('url')
        paramname: 'torrent[file]'
        maxfiles: 25
        maxfilesize: 5 # MB
        docEnter: -> $dropzone.addClass('invite') unless $dropzone.hasClass('invite')
        docLeave: -> $dropzone.removeClass('invite') if $dropzone.hasClass('invite')
        dragEnter: -> $dropzone.addClass('hover') unless $dropzone.hasClass('hover')
        dragLeave: -> $dropzone.removeClass('hover') if $dropzone.hasClass('hover')
        uploadFinished: (i, file, response, time) ->
          $.getScript(response.prepend_url)
        error: (err,file) ->
          switch err
            when 'BrowserNotSupported' then alert('browser does not support html5 drag and drop')
            when 'FileTooLarge' then alert("file #{file.name} is too large, max 5MiB")
