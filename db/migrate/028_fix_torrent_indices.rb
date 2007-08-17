class FixTorrentIndices < ActiveRecord::Migration
  def self.up
    remove_index "comments", :name => "index_comments_on_content"
    remove_index "torrents", :name => "index_torrents_on_description"
    remove_index "torrents", :name => "index_torrents_on_title"
    add_index "torrents", :status
    add_index "comments", :torrent_id
    add_index "comments", :user_id
    add_index "feeds", :user_id
    add_index "settings", :var
    add_index "watchings", :user_id
    add_index "watchings", :torrent_id
    add_index "watchings", :position
    
  end

  def self.down
    add_index "comments", ["content"], :name => "index_comments_on_content"
    add_index "torrents", ["description"], :name => "index_torrents_on_description"
    add_index "torrents", ["title"], :name => "index_torrents_on_title"
    remove_index "torrents", :name => "index_torrents_on_status"
    remove_index "comments", :name => "index_comments_on_torrent_id"
    remove_index "comments", :name => "index_comments_on_user_id"
    remove_index "feeds", :name => "index_feeds_on_user_id"
    remove_index "settings", :name => "index_settings_on_var"
    remove_index "watchings", :name => "index_watchings_on_user_id"
    remove_index "watchings", :name => "index_watchings_on_torrent_id"
    remove_index "watchings", :name => "index_watchings_on_position"
  end
end
