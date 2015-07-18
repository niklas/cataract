require 'spec_helper'

describe Cataract::TransferAdapters::RTorrentAdapter do
  let(:incoming) { incoming = create :existing_directory, relative_path: "incoming" }
  it "has an offline mode" do
    described_class.offline!
    described_class.should be_offline
  end

  it { described_class.should < XMLRPC::Client }
  it { described_class.should < XMLRPC::ClientS }

  let(:rtorrent) do
    described_class.new(rtorrent_socket_path)
  end

  let(:info_hash) { double('InfoHash') }
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

  it { rtorrent.should respond_to(:start!) }
  it { rtorrent.should respond_to(:stop!) }
  it { rtorrent.should respond_to(:close!) }
  it { rtorrent.should respond_to(:erase!) }
  it { rtorrent.should respond_to(:size_bytes) }
  # TODO complete list

  context "for torrent" do
    let(:torrent)  { double('Torrent', :info_hash => info_hash) }
    # FIXME WTF what does the torrent do here?
    let(:proxy) do
      described_class.new(rtorrent_socket_path).tap do |remote|
        remote.stub(:torrents).and_return({}) # provoke getting attributes by single calls
      end
    end


    it "should throw error when torrent has no info hash" do
      torrent_without_info_hash = double 'Torrent', :info_hash => nil
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
      let(:value) { double 'Value' }
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

  describe "apply" do
    let(:archived) { create :torrent  }
    let(:torrent) { create :torrent_with_picture_of_tails, content_directory: incoming }
    before :each do
      rtorrent.stub(:multicall).and_return(progress_array)
      rtorrent.apply torrents, [:up_rate, :down_rate, :active?]
    end

    context "for started torrent" do
      let(:torrents) { [torrent, archived] }
      let(:progress_array) { [{
        hash: torrent.info_hash,
        up_rate: 23,
        down_rate: 42,
        :"active?" => '1'
      }] }
      let(:transfer) { torrent.transfer }

      it "should set up rate" do
        transfer.up_rate.should_not be_nil
        transfer.up_rate.should == 23
      end

      it "should set down rate" do
        transfer.down_rate.should_not be_nil
        transfer.down_rate.should == 42
      end

      it "should set active state" do # so the TransferController can mark them as stopped
        transfer.should be_active
        archived.transfer.should_not be_active
      end

    end

    context "for archived torrent" do
      let(:torrents) { [ archived ] }
      let(:progress_array) { [] }
      let(:transfer) { archived.transfer }

      it "should not set rates" do
        transfer.up_rate.should be_nil
        transfer.down_rate.should be_nil
      end

    end

  end

  context "running" do
    let(:fields) {[
      :up_rate,
      :down_rate,
      :active?,
      :open?,
      :completed_bytes,
    ]}
    let(:rtorrent) do
      described_class.new(rtorrent_socket_path, fields: fields)
    end
    before { start_rtorrent }
    after  { stop_rtorrent }

    context "with two loaded torrents" do
      before do
        described_class.online!
        create_file incoming.full_path/'tails.png'
        @first   = create :torrent_with_picture_of_tails, content_directory: incoming
        @first.start!
        @second  = create :torrent_with_picture_of_tails_and_a_poem, content_directory: incoming
        @second.load!
        sleep 1 # rtorrent needs a moment
      end

      let(:results) { rtorrent.all() }
      let(:first_result) { results.find { |r| r.info_hash == @first.info_hash } }
      let(:second_result) { results.find { |r| r.info_hash == @second.info_hash } }

      # put it all in one block to reduce test suite runtime
      context '#all' do
        subject { rtorrent.all }
        it 'returns transfers for each torrent' do
          results.should have(2).records

          results.each do |result|
            result.should be_a(Cataract::Transfer)
          end

          first_result.should be_present
          first_result.completed_bytes.should == 73451

          second_result.should be_present
          second_result.completed_bytes.should be_zero
        end
      end
    end

  end

end
