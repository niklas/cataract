require File.dirname(__FILE__) + '/lib/lcars'

Lcars::INCLUDEES.each do |cls|
  cls.send! :include, Lcars
end
