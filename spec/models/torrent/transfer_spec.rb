require 'spec_helper'

describe Torrent, 'transfer' do
  before { start_rtorrent }
  after  { stop_rtorrent }

  it "is started automatically if asked" do
    incoming = create :directory
    torrent = create :torrent_with_picture_of_tails, start_automatically: true, content_directory: incoming
    torrent.should be_running
  end
end
