require 'spec_helper'
require 'torrent_fetcher'

describe TorrentFetcher do

  shared_examples :fetcher_successfully_creating_torrent do
    let(:cassette) { url.gsub(/\//,'_').gsub(/[^\w.]/,'') }
    it 'downloads and creates torrent' do
      VCR.use_cassette cassette do
        expect {
          subject.process(url)
        }.to change(Torrent, :count).by(1)
        Torrent.first.should be_file_exist
      end
    end
  end

  describe 'torrentz.eu -> kickass.to' do
    let(:url) { 'http://torrentz.eu/962fcfa03b061506e2e133ac4b5c8bc5151c4c6a' }
    it_should_behave_like :fetcher_successfully_creating_torrent
  end

  describe 'torrentz.eu -> baymirror.com' do
    let(:url) { 'http://torrentz.eu/bba51ddc73dc1f3bceaaa8ca7796fabe1a1a7935' }
    it_should_behave_like :fetcher_successfully_creating_torrent
  end

end
