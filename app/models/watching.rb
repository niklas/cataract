class Watching < ActiveRecord::Base
  belongs_to :torrent
  belongs_to :user
  validates_uniqueness_of :user, :scope => :torrent_id, :message => 'you can watch a torrent only once, else you would see double'
end
