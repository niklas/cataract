$ = jQuery
$spinner = $( "<div class='mini ui-loader ui-body-a ui-corner-all'><span class='ui-icon ui-icon-loading spin'></span></div>" )
jQuery ->
  $('body')
    .append( $s = $spinner.clone() )
    .ajaxStart -> $s.show()
    .ajaxStop  -> $s.hide()

