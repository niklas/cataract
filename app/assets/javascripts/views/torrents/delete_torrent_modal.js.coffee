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

Cataract.DeleteTorrentModal = Cataract.ModalPane.extend
  torrent: null
  heading: "Delete Torrent"
  bodyViewClass: Cataract.TorrentConfirmDeletionView
  primary: "Delete"
  secondary: "Keep"
  deletePayload: true
  ok: (opts) ->
    torrent = @get('torrent')
    if @get('deletePayload')
      torrent.clearPayload()?.then ->
        torrent.destroyRecord()
    else
      torrent.destroyRecord()
