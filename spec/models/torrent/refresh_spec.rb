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

  end
end
