class Feed < ActiveRecord::Base
  has_many :filters
  validates_presence_of :url, :message => "URL is needed"
  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
  validates_presence_of :title, :message => "please give a title"

  before_validation :set_url_as_title

  def self.avaiable(url)
    # very poor check if the page is avaiable
    url =~ /oo/
  end

  def items
    %w(Foo Bar Baz)
  end

  private
  def set_url_as_title
    self.title = self.url if !self.title or self.title.empty?
  end
end
