Cataract.TorrentConfirmDeletionView = Ember.View.extend
  template: Ember.Handlebars.compile """
    {{#if torrent.payloadExists}}
      <label>
        {{view Ember.Checkbox checkedBinding="view.parentView.deletePayload"}}
        Also delete payload
        <span class="size">{{torrent.payload.humanSize}}</span>
      </label>
    {{/if}}
  """
