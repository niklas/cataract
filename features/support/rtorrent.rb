Before '~@rtorrent' do
  Cataract.transfer_adapter_class.offline!
end

require Rails.root/'spec/support/rtorrent_spec_helper'
World(RTorrentSpecHelper)

Before '@rtorrent' do
  Torrent.stub(:rtorrent_socket_path).and_return(rtorrent_socket_path)
  start_rtorrent
end

After do
  stop_rtorrent
end

When /^rtorrent shuts down$/ do
  stop_rtorrent
end


Then /^the rtorrent (\w+) view (should|should not) contain #{capture_model}$/ do |view, should_or_not, m|
  should_or_not.gsub!(/\s/,'_')
  Cataract.transfer_adapter.download_list(view).send should_or_not, include( model!(m).info_hash )
end

Then /^rtorrent should download #{capture_model}$/ do |m|
  torrent = model!(m)
  torrent.info_hash.should_not be_blank
  Cataract.transfer_adapter.all(:active?).select {|r| r.info_hash ==  torrent.info_hash}.should be_present
end

Given /^rtorrent list contains the following:$/ do |table|
  table.map_column!('hash') do |hash|
    if hash =~ /^#{capture_model}$/
      model!(hash).info_hash
    else
      hash
    end
  end
  # we recreate RTorrent interface on every request
  adapters = Cataract.transfer_adapter_class.any_instance
  adapters.stub(:multicall).and_return(table.hashes.map(&:symbolize_keys))
  adapters.stub(:offline?).and_return(false)
end

