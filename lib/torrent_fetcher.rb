require 'maulwurf'
class TorrentFetcher < Maulwurf
  page %r~http://torrentz.eu/\w{40}~ => follow('kickass.to')
  page %r~http://kickass.to/[^/]+.html~ => follow(css: '#mainDetailsTable .downloadButtonGroup a', title: 'Download torrent file')
  file 'application/x-bittorrent' => :create_torrent

  def create_torrent(response)
    Torrent.create payload_data: response.body
  end
end
