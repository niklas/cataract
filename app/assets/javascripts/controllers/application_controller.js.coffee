Cataract.ApplicationController = Ember.Controller.extend
  init: ->
    Cataract.addObserver 'siteTitle', Cataract, (sender, key) -> $('head title').text("#{sender.get(key)} - Cataract")
    Cataract.set('siteTitle', 'loading')
    @_super()
    Cataract.set 'directories', Cataract.Directory.find()
    Cataract.set 'disks', Cataract.Disk.find()
    Cataract.set 'moves', Cataract.Move.find()
    Cataract.set 'transfers', Cataract.Transfer.find()
    Cataract.Torrent.find()
    $('body').bind 'tick', -> Cataract.refreshTransfers(); true
  terms: ''
  mode: ''
  setSiteTitle: (->
    title = "#{@get('mode')} torrents"
    if @get('terms').length > 0
      title += " containing '#{@get('terms')}'"
    if @get('directory')
      title += " in \"#{@get('directory').get('name')}\""
    Cataract.set 'siteTitle', title
  ).observes('torrentsFilterFunction')

  torrentsFilterFunction: (->
    terms  = Ember.A( Ember.String.w(@get('terms')) ).map (x) -> x.toLowerCase()
    mode = @get('mode')
    (torrent) ->
      want = true
      torrent = torrent.record if torrent.record? # materialized or not?!
      text = "#{torrent.get('title')} #{torrent.get('filename')}".toLowerCase()
      want = want and terms.every (term) -> text.indexOf(term) >= 0

      if mode.length > 0
        if mode == 'running'
          want = want and torrent.get('status') == 'running'

      if directory = Cataract.get('currentDirectory')
        want = want and directory is torrent.get('contentDirectory')

      want
  ).property('terms', 'mode', 'Cataract.currentDirectory')

  torrents: (->
    Cataract.store.filter(Cataract.Torrent, @get('torrentsFilterFunction'))
  ).property('torrentsFilterFunction')

