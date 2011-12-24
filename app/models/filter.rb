# == Schema Information
# Schema version: 36
#
# Table name: filters
#
#  id         :integer       not null, primary key
#  expression :string(255)   
#  feed_id    :integer       
#  negated    :boolean       
#  position   :integer       
#

class Filter < ActiveRecord::Base
  belongs_to :feed
  acts_as_list :scope => :feed_id
  validates_presence_of :expression, :message => "please give a regular expression (words work, too)"
  before_validation :positive_is_default

  scope :positive, where(:negated => false)
  scope :negated, where(:negated => true)

  def hits?(term)
    if negated?
      term !~ regexp
    else
      term =~ regexp
    end
  end
  def matches?(term)
    term =~ regexp
  end
  def expression=(new_expression)
    @regexp = nil
    self[:expression] = new_expression
  end
  def regexp
    @regexp ||= Regexp.new expression, true
  end

  private
  def positive_is_default
    if self[:negated].nil?
      self[:negated] = false
    end
  end
end
