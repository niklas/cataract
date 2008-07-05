Event.addBehavior.reassignAfterAjax = true
Event.addBehavior({
    '.torrent a' : Remote.Link,
    'div#helm > div.top a' : Remote.LinkWithBusy('helm'),
    'div.lcars ul.buttons > li > a ' : Remote.Link,
    'select#content_path' : SubDirSelector,
    'form.new_torrent #torrent_url': Observed(function(field,value) {
      new Ajax.Request('/torrents/new/probe?url=' + value, {method: 'put'});
    }, {frequency: 1}),
    'form.new_torrent': Remote
});
