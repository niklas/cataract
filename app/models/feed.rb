class Feed < ActiveRecord::Base
  validates_presence_of :url
  validates_format_of :url, :with => URI.regexp
  validates_presence_of :title

  before_validation :set_url_as_title

  private
  def set_url_as_title
    self.title = self.url if self.title.blank?
  end
end
