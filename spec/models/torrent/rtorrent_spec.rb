require 'spec_helper'

describe Torrent do
  let(:info_hash) { mock('InfoHash') }

  describe "proxy to rtorrent" do

    let(:proxy)     { mock('Torrent::RTorrent') }
    let(:torrent)   { build :torrent }

    before { Torrent.reset_remote! }

    it "should be initialized with pathname" do
      Torrent::RTorrent.should_receive(:new).with(kind_of(Pathname)).and_return(proxy)
      torrent.remote.should == proxy
    end

    it "uses fixed socket path" do
      Torrent.rtorrent_socket_path.should be_a(Pathname)
      path = mock 'socket path'
      Torrent.stub(:rtorrent_socket_path).and_return(path)
      Torrent::RTorrent.should_receive(:new).with(path)
      torrent.remote
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
    it "should delegate ##{meth} to proxy, supplying itself" do
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
    let(:torrent)  { mock('Torrent', :info_hash => info_hash) }
    let(:proxy) { described_class.new(torrent) }

    it "should respond to hardcoded methods" do
      Torrent::RTorrent::Methods.each do |meth|
        proxy.should respond_to(meth)
      end
    end

    it "should throw error when torrent has no info hash" do
      torrent_without_info_hash = mock 'Torrent', :info_hash => nil
      expect { proxy.up_rate(torrent_without_info_hash) }.to raise_error(Torrent::HasNoInfoHash)
    end

    it "should throw error if passed model does not respond to info_hash" do
      expect { proxy.up_rate("<no torrent>") }.to raise_error(Torrent::HasNoInfoHash)
    end

    context "calling getters" do
      [:up_rate, :up_total, :down_rate, :down_total, :size_bytes, :message, :completed_bytes].each do |getter|
        it "should use info hash for #{getter}" do
          proxy.should_receive(:call).with("d.get_#{getter}", info_hash).and_return(23)
          proxy.public_send(getter, torrent).should == 23
        end
      end
    end

    context "calling booleans" do
      [:open?, :active?].each do |bool|
        { 0 => false, 1 => true }.each do |int, out|
          it "should use info hash for #{bool}" do
            proxy.should_receive(:call).with("d.is_#{bool.to_s.chop}", info_hash).and_return(int)
            proxy.public_send(bool, torrent).should == out
          end
        end
      end
    end

    context "non-torrent related methods" do
      let(:value) { mock 'Value' }
      {
        :download_list => 'download_list'
      }.each do |meth, xml|
        it "should use no arguments for #{meth}" do
          proxy.should_receive(:call).with(xml).and_return(value)
          proxy.public_send(meth).should == value
        end
      end
    end

  end
end