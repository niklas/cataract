# == Schema Information
# Schema version: 33
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

  scope_out :negated, :conditions => { :negated => true }
  scope_out :positive, :conditions => { :negated => false }

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
end
