require 'lib/box'

ActionView::Base.send! :include, LcarsBox::InstanceMethods
