# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120429223056) do

  create_table "comments", :force => true do |t|
    t.integer  "torrent_id"
    t.integer  "user_id"
    t.string   "content"
    t.datetime "created_at"
  end

  add_index "comments", ["torrent_id"], :name => "index_comments_on_torrent_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "directories", :force => true do |t|
    t.string   "name"
    t.string   "path",          :limit => 2048
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_sub_dirs",                 :default => false
    t.boolean  "watched"
    t.string   "ancestry"
    t.integer  "disk_id"
  end

  add_index "directories", ["ancestry"], :name => "index_directories_on_ancestry"
  add_index "directories", ["disk_id"], :name => "index_directories_on_disk_id"

  create_table "disks", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "path"
  end

  create_table "feeds", :force => true do |t|
    t.string   "url",        :limit => 2048
    t.string   "title"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "fetched_at"
    t.datetime "synced_at"
    t.integer  "item_limit",                 :default => 100
  end

  add_index "feeds", ["user_id"], :name => "index_feeds_on_user_id"

  create_table "filters", :force => true do |t|
    t.string  "expression"
    t.integer "feed_id"
    t.boolean "negated"
    t.integer "position"
  end

  create_table "log_entries", :force => true do |t|
    t.string   "action"
    t.string   "level"
    t.integer  "user_id"
    t.text     "message"
    t.integer  "loggable_id"
    t.string   "loggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maintenances", :force => true do |t|
    t.datetime "locked_at"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moves", :force => true do |t|
    t.integer  "torrent_id"
    t.datetime "locked_at"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.string   "var",        :null => false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["var"], :name => "index_settings_on_var"

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "torrents", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "content_size"
    t.string   "filename"
    t.boolean  "hidden"
    t.string   "command"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.text     "url"
    t.integer  "feed_id"
    t.datetime "synched_at"
    t.text     "content_filenames"
    t.string   "info_hash",            :limit => 40
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "content_directory_id"
    t.integer  "directory_id"
    t.string   "content_path_infix"
    t.integer  "series_id"
  end

  add_index "torrents", ["content_directory_id"], :name => "index_torrents_on_content_directory_id"
  add_index "torrents", ["directory_id"], :name => "index_torrents_on_directory_id"
  add_index "torrents", ["filename"], :name => "index_torrents_on_filename"
  add_index "torrents", ["status"], :name => "index_torrents_on_status"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.string   "email",                   :limit => 128, :default => "", :null => false
    t.string   "jabber"
    t.boolean  "notify_via_jabber"
    t.boolean  "notify_on_comments"
    t.boolean  "notify_on_my_torrents"
    t.string   "picture_url"
    t.string   "encrypted_password",      :limit => 128, :default => "", :null => false
    t.string   "password_salt",                          :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "notify_on_new_torrents"
    t.boolean  "dont_watch_new_torrents"
    t.text     "content_dir_mountpoint"
    t.text     "target_dir_mountpoint"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.string   "reset_password_token"
    t.integer  "sign_in_count",                          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  create_table "watchings", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "torrent_id", :null => false
    t.datetime "created_at"
    t.boolean  "apprise"
    t.integer  "position"
  end

  add_index "watchings", ["position"], :name => "index_watchings_on_position"
  add_index "watchings", ["torrent_id"], :name => "index_watchings_on_torrent_id"
  add_index "watchings", ["user_id"], :name => "index_watchings_on_user_id"

end
