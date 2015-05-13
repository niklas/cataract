require 'spec_helper'

describe Torrent do
  let(:info_hash) { double('InfoHash') }

  describe "proxy to rtorrent" do

    let(:proxy)     { double('Cataract::TransferAdapters::RTorrentAdapter') }
    let(:proxy_class) { Cataract::TransferAdapters::RTorrentAdapter }
    let(:torrent)   { build :torrent }

    before { Torrent.reset_remote! }

    it "should be initialized with pathname" do
      proxy_class.should_receive(:new).with(kind_of(Pathname)).and_return(proxy)
      torrent.remote.should == proxy
    end

    it "uses fixed socket path" do
      Torrent.rtorrent_socket_path.should be_a(Pathname)
      path = double 'socket path'
      Torrent.stub(:rtorrent_socket_path).and_return(path)
      proxy_class.should_receive(:new).with(path)
      torrent.remote
    end

    it "should be cached" do
      torrent.remote.should == torrent.remote
    end

    it "should be reused on class level" do
      torrent.remote.should == Torrent.remote
    end

    it "should have attributes defined"
  end

end

