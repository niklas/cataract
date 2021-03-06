Cataract.TorrentConfirmDeletionView = Ember.View.extend
  template: Ember.Handlebars.compile """
    {{#with view.parentView.torrent}}
      {{#if payloadExists}}
        <label>
          {{view Ember.Checkbox checkedBinding="view.parentView.deletePayload"}}
          Also delete payload
          <span class="size">{{payload.humanSize}}</span>
        </label>
      {{/if}}
    {{/with}}
  """

Cataract.DeleteTorrentModal = Bootstrap.ModalPane.extend
  torrent: null
  heading: "Delete Torrent"
  bodyViewClass: Cataract.TorrentConfirmDeletionView
  primary: "Delete"
  secondary: "Keep"
  showBackdrop: true
  deletePayload: true
  callback: (opts) ->
    if opts.primary
      torrent = @get('torrent')
      torrent = torrent.get('content') if torrent.isController
      deletion = Cataract.Deletion.createRecord
        id: torrent.get('id')
        deletePayload: @get('deletePayload')
      deletion.store.commit()
      torrent.get('stateManager').goToState('deleted.saved')
    true
