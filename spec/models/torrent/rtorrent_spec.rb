require 'spec_helper'

describe Torrent do
  let(:info_hash) { mock('InfoHash') }

  describe "proxy to rtorrent" do

    it "should provide class methods for global settings"

    let(:proxy)     { mock('Torrent::RTorrent') }
    let(:torrent)   { build :torrent }

    before { Torrent.reset_remote! }

    it "should be initialized with pathname" do
      Torrent::RTorrent.should_receive(:new).with(kind_of(Pathname)).and_return(proxy)
      torrent.remote.should == proxy
    end

    it "should be cached" do
      torrent.remote.should == torrent.remote
    end

    it "should be reused on class level" do
      torrent.remote.should == Torrent.remote
    end

    it "should have hardcoded methods to accept" do
      Torrent::RTorrent::Methods.should_not be_empty
    end
  end

end

describe Torrent::RTorrent do
  it "has an offline mode" do
    described_class.offline!
    described_class.should be_offline
  end

  it "uses configured socket path"
  it { described_class.should < XMLRPC::Client }
  it { described_class.should < XMLRPC::ClientS }

  let(:rtorrent) do
    described_class.new(rtorrent_socket_path)
  end

  let(:info_hash) { mock('InfoHash') }
  let(:torrent) do 
    build :torrent, :info_hash => info_hash do |torrent|
      torrent.stub(:remote).and_return(rtorrent)
      torrent
    end
  end

  Torrent::RTorrent::Methods.each do |meth|
    it "should delegate ##{meth}" do
      rtorrent.should_receive(meth).with(torrent)
      torrent.public_send(meth)
    end
  end

  it "should throw error if cannot connect" do
    described_class.online! # offline by default in specs
    expect { rtorrent.remote_methods }.to raise_error
  end

  context "socket connection to rtorrent binary" do
    before { start_rtorrent }
    after  { stop_rtorrent }

    it "should have a list of methods available" do
      rtorrent.remote_methods.should_not be_empty
    end
  end


  context "for torrent" do
    let(:torrent)  { mock('Torrent') }
    let(:proxy) { described_class.new(torrent) }

    it "should respond to hardcoded methods" do
      Torrent::RTorrent::Methods.each do |meth|
        proxy.should respond_to(meth)
      end
    end
  end
end
