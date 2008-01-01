class UppercaseInfoHashes < ActiveRecord::Migration
  def self.up
    execute('UPDATE torrents SET info_hash=upper(info_hash) WHERE info_hash IS NOT NULL')
  end

  def self.down
    puts "nothing to downgrade"
  end
end
