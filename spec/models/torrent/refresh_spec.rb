require 'spec_helper'

describe Torrent do
  it "should support syncing" do
    Torrent.new.should respond_to(:refresh!)
  end
  describe 'refreshing' do

    describe 'a running torrent that was stopped manually' do
      before do
        Torrent.remote.stub(:torrents).once.and_return([])
      end
      let(:torrent) { Factory :running_torrent }

      it "should mark the torrent as archived" do
        torrent.refresh!
        torrent.status.should == 'archived'
      end
    end

    describe 'a running torrent that was stopped manually' do
      before do
        Torrent.remote.stub(:torrents).once.and_return([
          { hash: torrent.info_hash, active?: false }
        ])
      end
      let(:torrent) { Factory :running_torrent }

      it "should mark the torrent as archived" do
        torrent.refresh!
        torrent.status.should == 'archived'
      end
    end

    describe 'a torrent with a lost file' do
      let(:dir)     { Factory :existing_directory, path: 'media/incoming' }
      let(:torrent) { Factory :torrent, filename: 'lost.torrent' }
      it "is found directly in directory" do
        torrent.should_not be_file_exists
        Mlocate.stub(:file).with('lost.torrent').and_return([dir.path/'lost.torrent'])
        torrent.refresh!
        torrent.directory.should == dir
      end

      it "is not assigned in subdirectory" do
        torrent.should_not be_file_exists
        Mlocate.stub(:file).with('lost.torrent').and_return([dir.path/'deeply'/'nested'/'lost.torrent'])
        torrent.refresh!
        torrent.directory.should_not == dir
      end
    end

    describe 'a torrent with lost content' do
      let(:dir)     { Factory :existing_directory, path: 'pics/cats' }
      let(:torrent) { Factory :torrent_with_picture_of_tails }

      it "is found directly in existing directory" do
        Mlocate.stub(:file).with('tails.png').and_return([dir.path/'tails.png'])
        torrent.refresh!
        torrent.content_directory.should == dir
      end

      it "is found nested in existing directory" do
        Mlocate.stub(:file).with('tails.png').and_return([dir.path/'deeply'/'nested'/'tails.png'])
        torrent.refresh!
        torrent.content_directory.should == dir
        torrent.content_path_infix.should == 'deeply/nested'
      end

      it "is found as a whole when multiple files"
    end
  end
end
