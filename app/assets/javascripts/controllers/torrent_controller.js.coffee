Cataract.TorrentController = Ember.ObjectController.extend
  needs: ['torrents', 'directories', 'disks']

  actions:
    move: (torrent) ->
      directory = torrent.get('payload.directory') || torrent.get('contentDirectory')
      # TODO group directories by relative_path and show only one
      Cataract.MovePayloadModal.popup
        torrent: torrent
        directories: @get('controllers.directories.poly.directories')
        disks: @get('controllers.disks').get('content')
        move: Cataract.Move.createRecord
          targetDisk: directory.get('disk')
          targetDirectory: directory

    start: (torrent) ->
      transfer = @get('store').createRecord 'transfer',
        torrent: torrent
      transfer.save().then ->
        torrent.set 'status', 'running'
      false

    stop: (torrent) ->
      if transfer = torrent.get('transfer')
        transfer.destroyRecord().then ->
          torrent.set 'status', 'archived'
      false

    delete: (torrent) ->
      queryParams = Cataract.Router.router.currentParams.queryParams
      Cataract.DeleteTorrentModal.popup
        torrent: torrent
        backRoute: ['torrents.index', queryParams: queryParams]

    deletePayload: (torrent) ->
      Cataract.ClearPayloadModal.popup torrent: torrent
