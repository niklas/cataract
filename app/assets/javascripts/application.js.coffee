# =require endless_page
# =require spinner

$ = jQuery

$( 'body' ).live 'pageinit', (event) ->
  $('ul.torrents').endlessPage()
