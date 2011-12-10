require File.dirname(__FILE__) + '/../spec_helper'

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
  describe "status" do
    it "should default to 'new'" do
      pending
      Factory(:torrent).status.should == 'new'
    end

    it "should be specifiable" do
      pending
      Factory(:torrent, :status => 'running').status.should == 'running'
    end
  end
  describe "remote" do
    context "not reachable" do
      it "should catch the error"
    end
  end

  context "metainfo" do
    let(:torrent) { Factory :torrent }

    it "should raise Torrent::FileNotFound when file does not exist" do
      torrent.stub!(:file_exists?).and_return(false)
      expect { torrent.metainfo }.to raise_error(Torrent::FileNotFound)
    end

    it "should raise Torrent::FileNotFound when RubyTorrent::Metainfo cannot find file" do
      torrent.stub!(:file_exists?).and_return(true)
      RubyTorrent::MetaInfo.stub!(:from_bstream).and_raise(Errno::ENOENT)
      expect { torrent.metainfo }.to raise_error(Torrent::FileNotFound)
    end
  end
end

