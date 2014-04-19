Cataract.ApplicationController = Ember.Controller.extend
  init: ->
    @_super()
    @get('fullSiteTitle') # observer does not fire if value is not used

  needs: ['torrents', 'directories', 'disks']

  currentController: null

  fullSiteTitleObserver: ( (sender, key) ->
    $('head title').text(sender.get(key))
  ).observes('fullSiteTitle')

  fullSiteTitle:
    Ember.computed ->
      if sub = @get('currentController.siteTitle')
        [ sub, @get('siteTitle')].join(' - ')
      else
        "loading Cataract"
    .property('currentController.siteTitle')

  siteTitle: 'Cataract'
