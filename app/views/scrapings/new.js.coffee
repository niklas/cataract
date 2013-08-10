id = 'cataract_new_scraping'

current_path = ->
  <% if Rails.env.test? %>
  document.test_location
  <% else %>
  document.location.href
  <% end %>

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

  url = current_path()
  message "Scraping <i>#{url}</i>..."

  $.ajax '<%= scraping_url %>',
    data:
      url: url
    type: 'POST'
    dataType: 'json'
  .done (results) ->
    message r for r in results
    message $('<i>OK</i>').addClass('icon-ok').addClass('icon-white').attr('id', 'ok')
  .fail (results) ->
    message $('<i>not OK</i>').addClass('icon-bell').addClass('icon-white').attr('id', 'notok')
    message r for r in results


else
  alert "could not find jQuery on this site"

