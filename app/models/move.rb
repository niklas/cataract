class Move < ActiveRecord::Base

  belongs_to :torrent
  belongs_to :target, :class_name => 'Directory'

  validates_numericality_of :torrent_id
  validates_numericality_of :target_id

end
