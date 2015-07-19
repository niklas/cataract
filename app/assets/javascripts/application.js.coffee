#= require jquery
#= require jquery_ujs
#= require jquery.scrollTo-1.4.3.1
#= require moment
# early ember conf
#= require_self
#= require ember
#= require ember-data
#= require active-model-adapter
#= require ember-rails-flash
#= require bootstrap-sprockets
#= require bootstrap/modal
# FIXME must compile rails session
#= require ember-template-compiler
#= require pagination_support
#= require bindWithDelay
#
#= require ./lib/loaded_page
#= require cataract


window.EmberENV =
  nothing: true
  ENABLE_DS_FILTER: true

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
