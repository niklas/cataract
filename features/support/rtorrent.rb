Before '~@rtorrent' do
  Torrent::RTorrent.offline!
end

require Rails.root/'spec/support/rtorrent_spec_helper'
World(RTorrentSpecHelper)

Before '@rtorrent' do
  Torrent::RTorrent.online!
  start_rtorrent
end

After '@rtorrent' do
  stop_rtorrent
end

When /^I start #{capture_model}$/ do |m|
  model!(m).start!
end

Then /^rtorrent should show the following torrents:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

