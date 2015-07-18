#= require jquery
#= require jquery_ujs
#= require jquery.scrollTo-1.4.3.1
#= require moment
#= require ember
#= require ember-data
#= require ember-bootstrap
#= require ember-rails-flash
#= require bootstrap/dropdown
#= require bootstrap/modal
#= require pagination_support
#= require bindWithDelay
#
#= require ./cataract
#= require ./lib/loaded_page
#= require active-model-adapter
#= require_self
#= require cataract


window.EmberENV =
  nothing: true

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
  , if document.location.hostname is 'localhost' then 9001 * 1000 else 23 * 1000

  $.fn.animatedRemove = (duration=300)->
    $(this).each ->
      $e = $(this)
      $e.fadeOut duration, -> $e.remove()
