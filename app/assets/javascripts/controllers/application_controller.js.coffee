Cataract.ApplicationController = Ember.Controller.extend
  init: ->
    @addObserver 'fullSiteTitle', @, (sender, key) -> $('head title').text(sender.get(key))
    @_super()
    $('body').bind 'tick', -> Cataract.refreshTransfers(); true

  needs: ['torrents']

  currentController: null

  fullSiteTitle: Ember.computed ->
    if sub = @get('currentController.siteTitle')
      [ sub, @get('siteTitle')].join(' - ')
    else
      "loading Cataract"
  .property('currentController.siteTitle')

  siteTitle: 'Cataract'
