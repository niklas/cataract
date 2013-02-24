require 'spec_helper'

describe Torrent do
  it "should support syncing" do
    Torrent.new.should respond_to(:refresh!)
  end
  describe 'refreshing' do

    describe 'a running torrent that was stopped manually' do
      before do
        Torrent.remote.stub(:all).once.and_return([])
      end
      let(:torrent) { create :running_torrent }

      it "should mark the torrent as archived" do
        torrent.refresh!
        torrent.status.should == 'archived'
      end
    end

    describe 'a running torrent that was stopped manually' do
      before do
        Torrent.remote.stub(:all).once.and_return([
          { hash: torrent.info_hash, active?: false }
        ])
      end
      let(:torrent) { create :running_torrent }

      it "should mark the torrent as archived" do
        torrent.refresh!
        torrent.status.should == 'archived'
      end
    end

    describe 'a torrent with a lost file' do
      let(:dir)     { create :existing_directory, relative_path: 'media/incoming' }
      let(:torrent) { create :torrent, filename: 'lost.torrent' }
      it "is found directly in directory" do
        pending
        torrent.should_not be_file_exists
        Mlocate.stub(:file).with('lost.torrent').and_return([dir.full_path/'lost.torrent'])
        torrent.refresh!
        torrent.directory.should == dir
      end

      it "is not assigned in subdirectory" do
        pending
        torrent.should_not be_file_exists
        torrent.should_not be_file_exists
        Mlocate.stub(:file).with('lost.torrent').and_return([dir.full_path/'deeply'/'nested'/'lost.torrent'])
        torrent.refresh!
        torrent.directory.should_not == dir
      end
    end

    describe 'a torrent with lost content' do
      let(:dir)     { create :existing_directory, relative_path: 'pics/cats' }
      let(:torrent) { create :torrent_with_picture_of_tails }

      it "is found directly in existing directory" do
        Mlocate.stub(:file).with('tails.png').and_return([dir.full_path/'tails.png'].map(&:to_s))
        torrent.refresh!
        torrent.content_directory.should == dir
      end

      it "is found nested in existing directory" do
        Mlocate.stub(:file).with('tails.png').and_return([dir.full_path/'deeply'/'nested'/'tails.png'].map(&:to_s))
        torrent.refresh!
        torrent.content_directory.should == dir
        torrent.content_path_infix.should == 'deeply/nested'
      end

      it "is found as a whole containing multiple files" do
        torrent = create :torrent_with_picture_of_tails_and_a_poem
        Mlocate.should_receive(:postfix).with('content/tails.png').and_return([dir.full_path/'deeply'/'nested'/'content'/'tails.png'].map(&:to_s))
        torrent.refresh!
        torrent.content_directory.should == dir
        torrent.content_path_infix.should == 'deeply/nested'
      end
    end
  end
end
