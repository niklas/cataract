class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.column :url, :string, :limit => 2048
      t.column :title, :string
      t.column :user_id, :integer
      t.column :created_at, :datetime
      t.column :fetched_at, :datetime
    end
  end

  def self.down
    drop_table :feeds
  end
end
