require 'lib/box'

ActionView::Base.send! :include, LcarsBox::InstanceMethods
ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.send! :include, LcarsBox::InstanceMethods
