require 'spec_helper'
require 'rtorrent'

describe RTorrent do
  it { described_class.should < XMLRPC::Client }

  context "socket connection to rtorrent binary" do
    let(:rtorrent) do
      described_class.new(rtorrent_socket_path)
    end
    before { start_rtorrent }
    after  { stop_rtorrent }

    it "should have a list of methods available" do
      rtorrent.remote_methods.should_not be_empty
    end
  end
end
