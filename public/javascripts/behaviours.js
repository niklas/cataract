Event.addBehavior.reassignAfterAjax = true
Event.addBehavior({
    '#main .buttons a': Lcars.LinkTo('main', {message: "Searching"}),
    '.torrent a, a.torrent' : Lcars.LinkTo('helm', {message: "Loading Torrent"}),
    '#helm .buttons a' : Lcars.LinkTo('helm'),
    '#engineering .buttons a' : Lcars.LinkTo('engineering'),
    'select#content_path' : SubDirSelector,
    'form.new_torrent #torrent_url': Observed(function(field,value) {
      new Ajax.Request('/torrents/new/probe?url=' + value, {method: 'put'});
    }, {frequency: 1}),
    '#torrent_search': Lcars.SearchForm,
    'form.new_torrent': Remote,
    '#engineering ul#log' : Lcars.EndlessList
});
