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

    it "should have attributes defined" do
      Torrent::RTorrent::Attributes.should_not be_empty
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

  context "mass fetching" do
    let(:mapping) { rtorrent.torrents_mapping }
    it "should be a hash" do
      mapping.should be_a(Hash)
    end

    it "should have attributes set up" do
      mapping.should include({
        :hash             => "d.get_hash=",
        :name             => "d.get_name=",
        :size_bytes       => "d.get_size_bytes=",
        :completed_bytes  => "d.get_completed_bytes=",
        :up_rate          => "d.get_up_rate=",
        :down_rate        => "d.get_down_rate=",
        :active?           => "d.is_active=",
        #:size_files       => "d.get_size_files=",
        #:tracker_size     => "d.get_tracker_size=",
        #:chunk_size       => "d.get_chunk_size=",
        #:size_chunks      => "d.get_size_chunks=",
        #:completed_chunks => "d.get_completed_chunks=",
        #:ratio            => "d.get_ratio=",
        #:complete         => "d.get_complete=",
        #:priority         => "d.get_priority=",
      })
    end
  end

  it { rtorrent.should respond_to(:start!) }
  it { rtorrent.should respond_to(:stop!) }
  it { rtorrent.should respond_to(:close!) }
  it { rtorrent.should respond_to(:erase!) }
  it { rtorrent.should respond_to(:size_bytes) }
  # TODO complete list

  context "for torrent" do
    let(:torrent)  { mock('Torrent', :info_hash => info_hash) }
    # FIXME WTF what does the torrent do here?
    let(:proxy) do
      described_class.new(rtorrent_socket_path).tap do |remote|
        remote.stub(:torrents).and_return({}) # provoke getting attributes by single calls
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

  context "running" do
    before { start_rtorrent }
    after  { stop_rtorrent }

    context "with two loaded torrents" do
      before do
        described_class.online!
        incoming = create :existing_directory,
          relative_path: "incoming"
        create_file incoming.path/'tails.png'
        @first   = create :torrent_with_picture_of_tails,
          directory: incoming, content_directory: incoming
        @first.start!
        @second  = create :torrent_with_picture_of_tails_and_a_poem,
          directory: incoming, content_directory: incoming
        @second.load!
        sleep 10 # rtorrent needs a moment
      end

      context "mass fetching" do
        let(:list) { rtorrent.torrents }
        it "array" do
          list.should be_a(Array)
          list.should have(2).records
        end

        let(:map) { rtorrent.torrents_by_info_hash }
        it "by info_hash" do
          map.should be_a(Hash)
          map.should have(2).records
        end

        it "should index by info_hash" do
          map.keys.sort.should == list.map { |v| v[:hash] }.sort
        end

        let(:first) { list.first }
        let(:second) { list.second }

        it "should have attrs set" do
          first.should be_a(Hash)
          first.should be_matching({hash: @first.info_hash, completed_bytes: 73451}, :ignore_additional=>true)

          second.should be_a(Hash)
          second.should be_matching({hash: @second.info_hash}, :ignore_additional=>true)
        end
      end
    end

  end
end
