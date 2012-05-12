require 'spec_helper'

describe Torrent do
  
  context "with a valid URL" do
    let(:torrent) { build :remote_torrent, url: "http://localhost:1337/files/single.torrent" }

    context "marked for fetch automatically" do
      before do
        torrent.fetch_automatically = true
      end

      it "should fetch from url when saving" do
        torrent.should_receive(:fetch_from_url).and_return(true)
        torrent.save!
      end

    end

    it "should be downloadable" do
      response = mock('HTTP response', body: "torrent-data")
      Net::HTTP.stub(:get_response).and_return(response)
      expect { torrent.fetch_from_url }.to_not raise_error
      torrent.should have(:no).errors
      torrent.save!
      torrent.should be_persisted
    end
  end


end
