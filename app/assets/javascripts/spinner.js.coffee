# =require 'spin'
# =require 'jquery.spin'
$ = jQuery
jQuery ->
  $('body')
    .append( $s = $('<div id="spinner"></div>') )
    .ajaxStart -> $s.spin()
    .ajaxStop  -> $s.spin(false)

