require 'maulwurf'
class TorrentFetcher < Maulwurf
  page %r~http://torrentz.eu/\w{40}~ => [
    follow('kickass.to'),
    follow('monova.org'),
    follow('rarbg.com'),
    follow('torrentreactor.net'),
    follow('torrenthound.com'),
  ]
  page %r~http://kickass.to/[^/]+.html~ =>
    follow(css: '#mainDetailsTable .downloadButtonGroup a', title: /Download/)

  page %r~http://rarbg.com/torrent/~ =>
    follow(css: 'table.lista td.lista a[href^="/download.php"]')

  page %r~http://www.monova.org/torrent~ =>
    follow(css: '#downloadbox a[alt="Download!"]')

  page %r~http://www.torrentreactor.net/torrents/~ =>
    follow(css: 'a.thanks-page-link')

  page %r~http://www.torrenthound.com/hash~ =>
    follow(css: '#torrent a')

  file 'application/x-bittorrent' => :create_torrent

  def create_torrent(file, *a)
    t = Torrent.create! filedata: file.body,
                        filename: file.filename,
                        url: file.uri.to_s,
                        start_automatically: true
    log "downloaded"
    if t.running?
      log "started"
    end
    raise Done # FIXME detect more clever that we are done
  end
end
