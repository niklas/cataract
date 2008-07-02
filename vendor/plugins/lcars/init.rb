require File.dirname(__FILE__) + '/lib/box'

ActionView::Base.send! :include, LcarsBox::InstanceMethods
ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.send! :include, LcarsBox::InstanceMethods
ActionController::Base.send! :include, LcarsBox::InstanceMethods
