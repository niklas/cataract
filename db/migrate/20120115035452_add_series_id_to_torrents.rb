class AddSeriesIdToTorrents < ActiveRecord::Migration
  def change
    add_column :torrents, :series_id, :integer
  end
end
