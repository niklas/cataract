Event.addBehavior.reassignAfterAjax = true
Event.addBehavior({
    '#main .buttons a': Lcars.LinkTo('main'),
    '.torrent a, a.torrent' : Lcars.LinkTo('helm'),
    '#helm .buttons a' : Lcars.LinkTo('helm'),
    '#engineering .buttons a' : Lcars.LinkTo('engineering'),
    'select#content_path' : SubDirSelector,
    'form.new_torrent #torrent_url': Observed(function(field,value) {
      new Ajax.Request('/torrents/new/probe?url=' + value, {method: 'put'});
    }, {frequency: 1}),
    'form.new_torrent': Remote
});
