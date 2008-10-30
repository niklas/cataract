require File.dirname(__FILE__) + '/lib/lcars'

Lcars::INCLUDEES.each do |cls|
  cls.send! :include, Lcars
end

require File.dirname(__FILE__) + '/lib/active_record'
ActiveRecord::Base.class_eval do
  include Lcars::ActiveRecord
end
