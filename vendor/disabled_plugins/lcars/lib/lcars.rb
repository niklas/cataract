require File.dirname(__FILE__) + '/box'
require File.dirname(__FILE__) + '/decoration'
module Lcars
  INCLUDEES = [ ActionView::Base, ActionView::Helpers::PrototypeHelper::JavaScriptGenerator, ActionController::Base] unless defined?(INCLUDEES)
  InvalidLcarsNames = %w(page update lcars) unless defined?(InvalidLcarsNames)

  def lcars_box(name,opts={})
    box = Lcars::Box.new name, opts
    box.install INCLUDEES
    box
  end

  def list_of_lcars_boxes
    Lcars::Box::list_of_lcars_boxes
  end
end
