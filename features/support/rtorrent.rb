Before '~@rtorrent' do
  Torrent::RTorrent.offline!
end

require Rails.root/'spec/support/rtorrent_spec_helper'
World(RTorrentSpecHelper)

Before '@rtorrent' do
  Torrent.stub(:rtorrent_socket_path).and_return(rtorrent_socket_path)
  start_rtorrent
end

After '@rtorrent' do
  stop_rtorrent
end

When /^rtorrent shuts down$/ do
  stop_rtorrent
end


Then /^the rtorrent (\w+) view (should|should not) contain #{capture_model}$/ do |view, should_or_not, m|
  should_or_not.gsub!(/\s/,'_')
  Torrent.remote.download_list(view).send should_or_not, include( model!(m).info_hash )
end

Then /^rtorrent should download #{capture_model}$/ do |m|
  Torrent.remote.clear_caches!
  torrent = model!(m)
  torrent.info_hash.should_not be_blank
  remote = Torrent.remote.torrents_by_info_hash[torrent.info_hash]
  remote.should_not be_blank
  remote[:active?].should be_true
end

Given /^rtorrent list contains the following:$/ do |table|
  table.map_column!('hash') do |hash|
    if hash =~ /^#{capture_model}$/
      model!(hash).info_hash
    else
      hash
    end
  end
  Torrent.remote.stub(:torrents).and_return(table.hashes.map(&:symbolize_keys))
end

