Cataract.ApplicationController = Ember.Controller.extend
  init: ->
    @addObserver 'siteTitle', @, (sender, key) -> $('head title').text("#{sender.get(key)} - Cataract")
    @set('siteTitle', 'loading')
    @_super()
    Cataract.set 'directories', Cataract.Directory.find()
    Cataract.set 'disks', Cataract.Disk.find()
    Cataract.set 'moves', Cataract.Move.find()
    Cataract.set 'transfers', Cataract.Transfer.find()
    Cataract.Torrent.find()
    $('body').bind 'tick', -> Cataract.refreshTransfers(); true

  setSiteTitleByController: (controller) ->
    @set('siteTitle', controller.get('siteTitle'))

