# =require endless_page

jQuery ($) ->
  $( 'body' ).live 'pageinit', (event) ->
    $('ul.torrents').endlessPage()
