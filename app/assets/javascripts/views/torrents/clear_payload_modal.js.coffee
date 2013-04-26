Cataract.TorrentConfirmClearanceView = Ember.View.extend
  template: Ember.Handlebars.compile """
    {{#with view.parentView.torrent}}
      {{#if payloadExists}}
        Really delete the payload of '{{title}}'?
        (If you want it back, you'll have to restart it)
      {{else}}
        Looking for payload to clear..
      {{/if}}
    {{/with}}
  """

Cataract.ClearPayloadModal = Bootstrap.ModalPane.extend
  torrent: null
  heading: "Clear Torrent"
  bodyViewClass: Cataract.TorrentConfirmClearanceView
  primary: Ember.computed ->
   "Clear #{@get('torrent.payload.humanSize')}"
  .property('torrent.payload.humanSize')
  secondary: "still need it"
  showBackdrop: true
  callback: (opts) ->
    if opts.primary
      if payload = @get('torrent.payload')
        torrent = @get('torrent')
        payload.one 'didDelete', -> torrent.set('payloadExists', false)
        try
          payload.deleteRecord()
        catch error
          console?.debug "error while clearing payload: #{error}, trying to continue"
        payload.get('transaction').commit()
    true

