require 'spec_helper'
require 'rtorrent'

describe RTorrent do
  it { described_class.should < XMLRPC::Client }
  let(:rtorrent) do
    described_class.new(rtorrent_socket_path)
  end

  it "should throw error if cannot connect" do
    expect { rtorrent.remote_methods }.to raise_error
  end

  context "socket connection to rtorrent binary" do
    before { start_rtorrent }
    after  { stop_rtorrent }

    it "should have a list of methods available" do
      rtorrent.remote_methods.should_not be_empty
    end
  end
end
