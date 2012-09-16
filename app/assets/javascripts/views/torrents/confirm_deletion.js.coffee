Cataract.TorrentConfirmDeletionView = Ember.View.extend
  template: Ember.Handlebars.compile """
    {{#if torrent.payload}}
      <label>
        {{view Ember.Checkbox checkedBinding="view.parentView.deletePayload"}}
        Also delete payload
        <span class="size">{{torrent.payload.humanSize}}</span>
      </label>
    {{/if}}
  """
