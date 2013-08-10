id = 'cataract_new_scraping'

if jQuery
  $ = jQuery

  $('#' + id).remove()

  $box = $('<div></div')
    .attr('id', id)
    .css
      position: 'absolute'
      top: '23px'
      left: '23px'
      backgroundColor: '#141619'
      color: '#D7EEEE'
      padding: '10px'
      border: '2px solid #0099CC'
    .appendTo('body')

  message = (html) ->
    $('<div></div>')
      .html(html)
      .appendTo($box)

  message '<h3>Cataract</h3>'

  url = document.location
  message "Scraping <i>#{url}</i>..."

else
  alert "could not find jQuery on this site"

