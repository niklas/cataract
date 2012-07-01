require 'spec_helper'

describe Torrent, 'without title' do

  context "with filename present" do
    let(:torrent) { build :torrent, filename: 'milch.torrent' }
    it "is build by filename" do
      torrent.title.should == 'milch'
    end
  end

  context "with no filename, but url present" do
    let(:torrent) { build :torrent, filename: nil, title: nil, url: 'http://blubb.de/Spinat.torrent' }
    it "is build by last part of url" do
      torrent.title.should == 'Spinat'
    end
  end

  context "without filename and url present" do
    let(:torrent) { build :torrent, filename: nil, title: nil, url: nil}
    context "unsaved" do
      it "just says 'new'" do
        torrent.title.should == 'new Torrent'
      end
    end
    context "saved" do
      # may not even valid, but may already exist (legacy)
      it "is build by id" do
        torrent.stub(:persisted?).and_return(true)
        torrent.stub(:id).and_return(2342)
        torrent.title.should == "Torrent #2342"
      end
    end
  end
end
