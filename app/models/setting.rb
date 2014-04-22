class Setting < ActiveRecord::Base
  belongs_to :incoming_directory, class_name: 'Directory'
  belongs_to :torrent_directory, class_name: 'Directory'
  attr_accessible :disable_signup, :incoming_directory_id
  def self.singleton
    order(:created_at).last || new
  end

  attr_accessor :scraping_url
end
