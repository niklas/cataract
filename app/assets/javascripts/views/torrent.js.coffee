Cataract.TorrentView = Ember.View.extend
  classNames: ['well']
  attributeBindings: ['style']
  style: Ember.computed ->
    "position: relative; top: #{@get('offset') || 0}px;"
  .property('offset')
  offsetBinding: 'controller.content.offsetInList'
  didInsertElement: ->
    jQuery(window).scrollTo @$(), 500,
      axis: 'y'
      offset:
        top: -70
