class Feed < ActiveRecord::Base
  has_many :filters
  validates_presence_of :url, :message => "URL is needed"
  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
  validates_presence_of :title, :message => "please give a title"
end
