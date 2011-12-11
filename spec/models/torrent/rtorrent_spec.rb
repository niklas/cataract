require 'spec_helper'

describe Torrent do

  describe "proxy to rtorrent" do

    it "should provide class methods for global settings"

    let(:proxy)     { mock('Torrent::RTorrentProxy') }
    let(:info_hash) { mock('InfoHash') }

    it "should be initialized on instance level?" do
      torrent = build :torrent
      Torrent::RTorrentProxy.should_receive(:new).with(torrent).and_return(proxy)
      torrent.remote.should == proxy
      torrent.remote.should == proxy # is cached
    end

    let(:torrent) do 
      build :torrent, :info_hash => info_hash do |torrent|
        torrent.stub(:remote).and_return(proxy)
        torrent
      end
    end

    it "should have hardcoded methods to accept" do
      Torrent::MethodsForRTorrent.should_not be_empty
    end

    Torrent::MethodsForRTorrent.each do |meth|
      it "should delegate ##{meth}" do
        proxy.should_receive meth
        torrent.public_send(meth)
      end
    end
  end

  describe Torrent::RTorrentProxy do
    it "has an offline mode" do
      Torrent::RTorrentProxy.offline!
      Torrent::RTorrentProxy.should be_offline
    end


    context "for torrent" do
      let(:torrent) { mock('Torrent') }
      let(:proxy) do
        Torrent::RTorrentProxy.new(torrent)
      end

      let(:torrent_methods) { Torrent::MethodsForRTorrent }
      #it "should responded to hardcoded methods" do
      #  torrent_methods.each do |meth|
      #    proxy.should respond_to(meth)
      #  end
      #end
    end
  end

end
