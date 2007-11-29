# == Schema Information
# Schema version: 33
#
# Table name: comments
#
#  id         :integer       not null, primary key
#  torrent_id :integer       
#  user_id    :integer       
#  content    :string(255)   
#  created_at :datetime      
#

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :torrent
end
