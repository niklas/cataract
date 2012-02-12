# =require endless_page
# =require spinner

$ = jQuery

$( 'body' ).live 'pageinit', (event) ->
  $('ul.torrents').endlessPage()

  $('.ui-input-search input.ui-input-text').bind 'keyup change', ->
    $list = $(@).closest('form').find('+ul.ui-listview')
    $.ajax
      url: "#{$list.data('url')}"
      type: 'get'
      dataType: 'script'
      data:
        terms: @value

  $('.transfer_torrent .progress').bind 'click', ->

jQuery ->
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
