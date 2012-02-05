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
