require 'maulwurf'
class TorrentFetcher < Maulwurf
  page %r~http://torrentz.eu/\w{40}~ => [
    follow('kickass.to'),
    follow('monova.org'),
    follow('rarbg.com'),
    follow('torrentreactor.net'),
  ]
  page %r~http://kickass.to/[^/]+.html~ =>
    follow(css: '#mainDetailsTable .downloadButtonGroup a', title: 'Download torrent file')

  page %r~http://rarbg.com/torrent/~ =>
    follow(css: 'table.lista td.lista a[href^="/download.php"]')

  page %r~http://www.monova.org/torrent~ =>
    follow(css: '#downloadbox a[alt="Download!"]')

  page %r~http://www.torrentreactor.net/torrents/~ =>
    follow(css: 'a.thanks-page-link')

  file 'application/x-bittorrent' => :create_torrent

  def create_torrent(file, *a)
    Torrent.create! filedata: file.body, filename: file.filename, url: file.uri.to_s
    raise Done # FIXME detect more clever that we are done
  end
end
