class TagsReplaceFiltersForFeeds < ActiveRecord::Migration
  def self.up
    drop_table :filters
  end

  def self.down
    raise IrreversibleMigration
  end
end
