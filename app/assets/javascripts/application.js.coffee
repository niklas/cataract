#= require jquery
#= require jquery.ui.widget
#= require jquery_ujs
#= require bootstrap
#= require jquery.sausage
#= require endless_page
#= require spinner
#= require radio_buttons
#= require bindWithDelay

jQuery ->
  $('ul#torrents').endlessPage()

  $('form#new_torrent_search :radio').bind 'change', ->
    $(@).closest('form').submit()

  $('form#new_torrent_search :text').bindWithDelay 'keyup change', ->
    $(@).closest('form').submit()
  ,333


  $('#title').bind 'click', -> $('body').trigger 'tick'

  $('body').bind 'tick', ->
    active = $('.transfer_torrent').attr('id')
    if active?
      $.getScript '/torrents/' + active.replace(/^\D+/, '')
    else
      $.getScript '/torrents/progress'
    true

  setInterval ->
    $('body').trigger 'tick'
  , 23 * 1000

  $('body').on 'click', 'ul.torrents li.torrent', (event) ->
    url = $(event.currentTarget).find('a:first').attr('href')
    if url?
      window.location = url
