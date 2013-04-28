require 'spec_helper'

describe Torrent, 'creation' do

  context 'by url' do
    let(:url)     { "http://hashcache.net/files/single.torrent" }
    before :each do
      stub_request(:get, url).
         with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => File.read( FileSystem.file_factory_path/'single.torrent' ), :headers => {})

    end
    it "is valid" do
      build(:torrent, url: url).should be_valid
    end

    context 'with auto*' do
      let!(:directory) { create :existing_directory }
      let(:torrent) { build(:torrent, url: url, start_automatically: true, fetch_automatically: true) }

      before { start_rtorrent }
      after { stop_rtorrent }

      it "fetches and is started automatically" do
        expect do
          torrent.save!
        end.not_to raise_error
      end
    end
  end
end


