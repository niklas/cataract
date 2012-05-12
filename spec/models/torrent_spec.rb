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
      expect { torrent.metainfo }.to raise_error(Torrent::HasNoMetaInfo)
    end

    it "should raise Torrent::FileNotFound when RubyTorrent::Metainfo cannot find file" do
      torrent.stub!(:file_exists?).and_return(true)
      torrent.stub!(:path).and_return('path')
      RubyTorrent::MetaInfo.stub!(:from_bstream).and_raise(Errno::ENOENT)
      expect { torrent.metainfo }.to raise_error(Torrent::FileNotFound)
    end
  end

  context "in filesystem" do
    let(:storage) { create :existing_directory, relative_path: 'storage' }
    let(:archive) { create :existing_directory, relative_path: 'archive' }

    describe "with single file" do
      let(:torrent) do
        create :torrent_with_picture_of_tails, content_directory: archive do |torrent|
          create_file storage.path/torrent.filename
          torrent
        end
      end
      it "knows the path of its torrent file" do
        torrent.path.should_not be_blank
        torrent.path.to_s.should be_ends_with('single.torrent')
      end
      it "knows the full path of its content file" do
        torrent.content.files.should == [
          archive.path/'tails.png'
        ]
      end
      it "knows the name of its content file" do
        torrent.content.relative_files.should == [
          'tails.png'
        ]
      end
      # FIXME put this on the others in own torrent/content_spec
      it "content.path should point to file" do
        torrent.content.path.should == archive.path/'tails.png'
      end

      it "can be destroyed" do
        expect { torrent.destroy }.to_not raise_error
      end
    end

    describe "with multiple files" do
      let(:torrent) do
        create :torrent_with_picture_of_tails_and_a_poem, content_directory: archive do |torrent|
          create_file storage.path/torrent.filename
          torrent
        end
      end
      it "knows the path of its torrent file" do
        torrent.path.should_not be_blank
        torrent.path.to_s.should be_ends_with('multiple.torrent')
      end
      it "knows the relative paths of its content files" do
        torrent.content.relative_files.should == [
          'content/banane.poem',
          'content/tails.png'
        ]
      end
      it "knows the names of its content files" do
        torrent.content.files.should == [
          archive.path/'content'/'banane.poem',
          archive.path/'content'/'tails.png'
        ]
      end
      # FIXME put this on the others in own torrent/content_spec
      it "content.path should point to directory" do
        torrent.content.path.should == archive.path/'content'
      end
    end

    describe "settings" do
      before { create :setting, incoming_directory: storage }
      it "should define content directory" do
        create(:torrent, content_directory: nil).content_directory.should == storage
      end
    end

  end


  describe 'running' do
    let(:torrent) { build :torrent_with_picture_of_tails }
    it "should be stopped when clearing" do
      torrent.should_receive(:stop)
      torrent.content.destroy
    end
  end

  describe 'clean filenames' do
    let(:filename) { 'Fame of Bones 5x12 [720P - HDTV - OMMARZE].torrent' }
    let(:torrent)  { build(:torrent, filename: filename) }
    let(:cleaned)  { torrent.clean_filename }
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

end

