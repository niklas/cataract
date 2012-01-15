class Series < ActiveRecord::Base
  has_many :torrents
  validates_presence_of :title
end
