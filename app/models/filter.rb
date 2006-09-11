class Filter < ActiveRecord::Base
  belongs_to :feed
  validates_presence_of :expression, :message => "please give a regular expression"
end
