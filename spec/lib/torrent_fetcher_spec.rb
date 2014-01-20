require 'spec_helper'
require 'torrent_fetcher'

describe TorrentFetcher do

  describe 'for torrentz.eu' do
    let(:torrentz_eu) { 'http://torrentz.eu/962fcfa03b061506e2e133ac4b5c8bc5151c4c6a' }

    it 'downloads torrent' do
      Torrent.should_receive :create!
      VCR.use_cassette 'torrentz.eu_single' do
        subject.process(torrentz_eu)
      end
    end
  end

end
