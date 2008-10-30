Event.addBehavior.reassignAfterAjax = true
Event.addBehavior({
    '#main > .buttons a, #main div.pagination a': Lcars.LinkTo('main', {message: "Searching"}),
    'div.lcars#container > ul.buttons a': Lcars.LinkTo('container', {message: "Loading"}),
    '.torrent a, a.torrent' : Lcars.LinkTo('helm', {message: "Loading Torrent"}),
    '#helm .buttons a' : Lcars.LinkTo('helm'),
    '#engineering .buttons a' : Lcars.LinkTo('engineering'),
    'select#content_directory_id' : SubDirSelector,
    'form.new_torrent #torrent_url': Observed(function(field,value) {
      new Ajax.Request('/torrents/new/probe', {method: 'put', parameters: {url : value}});
    }, {frequency: 1}),
    '#torrent_search': Lcars.SearchForm,
    'form.new_torrent': Remote,
    '#engineering ul#log' : Lcars.EndlessList
});
