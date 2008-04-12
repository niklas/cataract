# == Schema Information
# Schema version: 35
#
# Table name: watchings
#
#  id         :integer       not null, primary key
#  user_id    :integer       not null
#  torrent_id :integer       not null
#  created_at :datetime      
#  apprise    :boolean       
#  position   :integer       
#

class Watching < ActiveRecord::Base
  belongs_to :torrent
  belongs_to :user
  validates_uniqueness_of :user_id, :scope => :torrent_id, :message => 'you can watch a torrent only once, else you would see double'
  acts_as_list :scope => :user_id
end
