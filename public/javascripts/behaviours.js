Event.addBehavior.reassignAfterAjax = true
Event.addBehavior({
    '.torrent a' : Remote.Link,
    'div#helm > div.top a' : Remote.LinkWithBusy('helm'),
    'div.lcars ul.buttons > li > a ' : Remote.Link,
    'select#content_path' : SubDirSelector
});
