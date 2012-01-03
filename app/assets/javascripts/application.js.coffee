# =require endless_page

$ = jQuery
$spinner = $( "<div class='mini ui-loader ui-body-a ui-corner-all'><span class='ui-icon ui-icon-loading spin'></span></div>" )

$( 'body' ).live 'pageinit', (event) ->
  $("div[data-role=header]")
    .append( $s = $spinner.clone() )
    .ajaxStart -> $s.show()
    .ajaxStop  -> $s.hide()

  $('ul.torrents').endlessPage()
