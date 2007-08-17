class Tag < ActiveRecord::Base
  has_many :taggings
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  class << self
    delegate :delimiter, :delimiter=, :to => TagList
  end

  def self.parse(list)
    tags = []
    
    return tags if list.blank?
    list = list.dup
    
    # Parse the quoted tags
    list.gsub!(/"(.*?)"\s*#{delimiter}?\s*/) { tags << $1; "" }
    
    # Strip whitespace and remove blank tags
    (tags + list.split(delimiter)).map!(&:strip).delete_if(&:blank?)
  end

  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end

    # Find the tags that are on the same object(s) like this tag
  def related_tags
    self.class.find(:all,
      :select => 'DISTINCT tags.id, tags.name',
      :joins => 
          'LEFT OUTER JOIN taggings ON tags.id = taggings.tag_id ' +
          'LEFT OUTER JOIN taggings ts ON taggings.taggable_id = ts.taggable_id ' +
          'LEFT OUTER JOIN tags this on ts.tag_id = this.id',
      :conditions => ['tags.id != ? AND this.id = ? AND taggings.taggable_type = ts.taggable_type', self.id, self.id ],
      :order => 'tags.name'
    )
  end
end
