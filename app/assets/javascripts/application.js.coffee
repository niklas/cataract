#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require jquery.scrollTo-1.4.3.1
#= require handlebars
#= require ember
#= require ember-emu-0.1.0
#= require ember-bootstrap
#= require ember-rails-flash
#= require bootstrap
#= require pagination_support
#= require bindWithDelay
#
#= require ./cataract

jQuery ->
  search = ->
    $(@).closest('form')
      .find('input.page').val(1).end()
      .submit()

  $('form#new_torrent_search :radio').bind 'change', search
  $('form#new_torrent_search :text').bindWithDelay 'keyup change', search, 333

  # TODO put refresh-click into Ember View
  $('#title').bind 'click', -> $('body').trigger 'tick'

  setInterval ->
    $('body').trigger 'tick'
  , 23 * 1000

  $.fn.animatedRemove = (duration=300)->
    $(this).each ->
      $e = $(this)
      $e.fadeOut duration, -> $e.remove()
