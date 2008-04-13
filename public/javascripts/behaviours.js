Event.addBehavior.reassignAfterAjax = true
Event.addBehavior({
    'div.torrent a' : Remote.LinkWithBusy('helm'),
    'div#helm > div.top a' : Remote.LinkWithBusy('helm'),
    '#main > div ul.buttons > li > a ' : Remote.LinkWithBusy('main'),
    'div.torrent > form > select#content_path' : SubDirSelector
});
