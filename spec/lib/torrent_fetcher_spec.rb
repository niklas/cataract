require 'spec_helper'
require 'torrent_fetcher'

describe TorrentFetcher do

  matcher :fetch_torrent_from do |url|
    match do |fetcher|
      cassette = url.gsub(/\//,'_').gsub(/[^\w.]/,'')
      VCR.use_cassette cassette do
        expect {
          fetcher.process(url)
        }.to change(Torrent, :count).by(1)
      end
      Torrent.first.file_exists?
    end
  end

  it 'fetches from torrentz.eu -> kickass.to' do
    should fetch_torrent_from('http://torrentz.eu/962fcfa03b061506e2e133ac4b5c8bc5151c4c6a')
  end
  it 'fetches from torrentz.eu -> rarbg.com' do
    should fetch_torrent_from('http://torrentz.eu/bba51ddc73dc1f3bceaaa8ca7796fabe1a1a7935')
  end
  it 'fetches directly from monova' do
    should fetch_torrent_from('http://www.monova.org/torrent/7456513/Time.Of.The.Wolf.2003.720p.BluRay.DTS.x264-PublicHD.html')
  end
end
