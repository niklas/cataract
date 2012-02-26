#= require jquery
#= require jquery.ui.widget
#= require jquery_ujs
#= require bootstrap
#= require jquery.sausage
#= require endless_page
#= require spinner

jQuery ->
  $('ul.torrents').endlessPage()

  $('#torrent_search_terms').bind 'keyup change', ->
    $(@).closest('form').submit()


  $('.transfer_torrent .progress').bind 'click', ->

  $('body').bind 'tick', ->
    active = $('.transfer_torrent').attr('id')
    if active?
      active = active.replace(/^\D+/, '')
    $.ajax
      url: '/torrents/progress'
      data:
        active: active
      type: 'get'
      dataType: 'script'
    true

  setInterval ->
    $('body').trigger 'tick'
  , 23 * 1000
