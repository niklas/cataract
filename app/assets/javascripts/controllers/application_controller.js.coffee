Cataract.ApplicationController = Ember.Controller.extend
  init: ->
    @addObserver 'siteTitle', @, (sender, key) -> $('head title').text("#{sender.get(key)} - Cataract")
    @set('siteTitle', 'loading')
    @_super()
    $('body').bind 'tick', -> Cataract.refreshTransfers(); true

  setSiteTitleByController: (controller) ->
    @set('siteTitle', controller.get('siteTitle'))

