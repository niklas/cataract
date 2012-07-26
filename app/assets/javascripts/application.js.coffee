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
#= require ember.js
#
#= require cataract/app

jQuery ->
  $('body:has(ul#torrents):has(form#new_torrent_search)').endlessSearch list: 'ul#torrents', form: 'form#new_torrent_search'

  search = ->
    $(@).closest('form')
      .find('input.page').val(1).end()
      .submit()

  $('form#new_torrent_search :radio').bind 'change', search
  $('form#new_torrent_search :text').bindWithDelay 'keyup change', search, 333

  $('#torrents').on 'click', '.torrent', (event)-> $(this).toggleClass('full') if $(event.target).is('div')

  $('#title').bind 'click', -> $('body').trigger 'tick'

  $('body').bind 'tick', ->
    running = $('#torrents .torrent.running').map -> $(this).attr('id').replace(/^\D+/, '')
    $.getScript "/progress?running=#{running.get().join(',')}"
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

  $('#dropzone').hide().each ->
    if supportAjaxUploadProgressEvents() and not isTouchDevice()
      $dropzone = $(this)
      $dropzone.filedrop
        url: $dropzone.data('url')
        paramname: 'torrent[file]'
        maxfiles: 25
        maxfilesize: 5 # MB
        docEnter: -> $dropzone.not(":visible").show()
        docLeave: -> $dropzone.filter(":visible").hide()
        dragEnter: -> $dropzone.addClass('hover') unless $dropzone.hasClass('hover')
        dragLeave: -> $dropzone.removeClass('hover') if $dropzone.hasClass('hover')
        uploadFinished: (i, file, response, time) ->
          $.getScript(response.prepend_url)
        error: (err,file) ->
          switch err
            when 'BrowserNotSupported' then alert('browser does not support html5 drag and drop')
            when 'FileTooLarge' then alert("file #{file.name} is too large, max 5MiB")

  $.fn.animatedRemove = (duration=300)->
    $(this).each ->
      $e = $(this)
      $e.fadeOut duration, -> $e.remove()
