Before '~@rtorrent' do
  Torrent::RTorrent.offline!
end

require Rails.root/'spec/support/rtorrent_spec_helper'
World(RTorrentSpecHelper)

Before '@rtorrent' do
  Torrent::RTorrent.online!
  Torrent.stub(:rtorrent_socket_path).and_return(rtorrent_socket_path)
  start_rtorrent
end

After '@rtorrent' do
  stop_rtorrent
end

When /^I load #{capture_model}$/ do |m|
  model!(m).load!
end

When /^I start #{capture_model}$/ do |m|
  model!(m).start!
end

Then /^the rtorrent (\w+) view should contain #{capture_model}$/ do |view, m|
  Torrent.remote.download_list(view).should include( model!(m).info_hash )
end

Then /^rtorrent should download #{capture_model}$/ do |m|
  torrent = model!(m)
  remote = Torrent.remote.torrents.find {|r| r[:hash] == torrent.info_hash }
  remote.should_not be_blank
  remote[:active].should == 1
end
