require 'maulwurf'
class TorrentFetcher < Maulwurf
  page %r~http://torrentz.eu/\w{40}~ => follow('kickass.to')
  page %r~http://kickass.to/[^/]+.html~ => follow(css: '#mainDetailsTable .downloadButtonGroup a', title: 'Download torrent file')
  file 'application/x-bittorrent' => :create_torrent

  def create_torrent(file, *a)
    Torrent.create! filedata: file.body, filename: file.filename, url: file.uri.to_s
    raise Done # FIXME detect more clever that we are done
  end
end
