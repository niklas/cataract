Cataract.TorrentConfirmClearanceView = Ember.View.extend
  template: Ember.Handlebars.compile """
    {{#if torrent.payloadExists}}
      Really delete the payload of '{{torrent.title}}'?
      (If you want it back, you'll have to restart it)
    {{else}}
      Looking for payload to clear..
    {{/if}}
  """

