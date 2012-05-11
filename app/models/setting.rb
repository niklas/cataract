class Setting < ActiveRecord::Base
  belongs_to :incoming_directory, class_name: 'Directory'
  belongs_to :torrent_directory, class_name: 'Directory'
  def self.singleton
    order(:created_at).last || new
  end
end
