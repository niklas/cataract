require 'spec_helper'

describe "A blank Torrent" do
  before(:each) do
    pending "cannot create torrent without rtorrent running"
    @torrent = Torrent.new(:url => '', :filename => '')
  end

  it "should not be valid" do
    @torrent.should_not be_valid
    @torrent.should have_at_least(1).error_on(:info_hash)
  end

  it "should not be safable" do
    lambda do
      @torrent.save
    end.should_not change(Torrent,:count).by(1)
  end

  it "should not be creatable" do
    lambda do
      Torrent.create(:url => '', :filename => '')
    end.should_not change(Torrent,:count).by(1)
  end
  it "should not fail saving" do
    lambda do
      @torrent.save
    end.should_not raise_error
  end
end

describe Torrent do

  context "bound to file" do
    let(:torrent) { build :torrent_with_picture_of_tails }
    it "needs the file not to be empty" do
      torrent.should be_valid
      File.truncate torrent.path, 0
      torrent.should_not be_valid
    end
    it "needs the file to be a valid .torrent"
  end
  describe "status" do
    it "should default to 'new'" do
      pending
      create(:torrent).status.should == 'new'
    end

    it "should be specifiable" do
      pending
      create(:torrent, :status => 'running').status.should == 'running'
    end
  end
  describe "remote" do
    context "not reachable" do
      it "should catch the error"
    end
  end

  context "metainfo" do
    let(:torrent) { create :torrent }

    it "should raise Torrent::FileNotFound when file does not exist" do
      torrent.stub!(:file_exists?).and_return(false)
      expect { torrent.metainfo }.to raise_error(Torrent::HasNoMetaInfo)
    end

    it "should raise Torrent::FileNotFound when RubyTorrent::Metainfo cannot find file" do
      torrent.stub!(:file_exists?).and_return(true)
      torrent.stub!(:path).and_return('path')
      RubyTorrent::MetaInfo.stub!(:from_bstream).and_raise(Errno::ENOENT)
      expect { torrent.metainfo }.to raise_error(Torrent::FileNotFound)
    end
  end


  describe 'running' do
    let(:torrent) { build :torrent_with_picture_of_tails }
    it "should be stopped when clearing" do
      torrent.should_receive(:stop)
      torrent.payload.destroy
    end
  end

  describe 'clean filenames' do
    let(:torrent)  { build(:torrent, filename: filename) }
    let(:cleaned)  { torrent.clean_filename }

    describe "pirate-bay style" do
      let(:filename) { 'Fame of Bones 5x12 [720P - HDTV - OMMARZE].torrent' }
      it "should keep the name" do
        cleaned.should include("Fame of Bones")
      end

      it "should keep season and episode" do
        cleaned.should include("5x12")
      end

      it "should keep 720P info" do
        cleaned.should include("720")
      end

      it "should remove brackets" do
        cleaned.should_not include("[")
        cleaned.should_not include("]")
      end

      it "should remove extension" do
        cleaned.should_not include(".torrent")
      end

      it "should remove release group" do
        cleaned.should_not include("OMMARZE")
      end
    end

    describe "Kickass-torrents style" do
      let(:filename) { "_kat.ph_the.peanut.penguins.s01e03.friday.night.fnords.hdtv.xvid.fqm.eztv.torrent" }
      it "should remove kat prefix" do
        cleaned.should_not include("_kat.ph_")
        cleaned.should_not include("kat")
        cleaned.should_not include("ph")
      end

      it "should keep season and episode" do
        cleaned.should include('s01e03')
      end

      it "should not include format" do
        cleaned.should_not include('xvid')
      end

      it "should not include release group" do
        cleaned.should_not include('fqm')
      end

      it "should not include eztv" do
        cleaned.should_not include('eztv')
      end
    end
  end

end

