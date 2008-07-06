require File.dirname(__FILE__) + '/box'
module Lcars
  INCLUDEES = [ ActionView::Base, ActionView::Helpers::PrototypeHelper::JavaScriptGenerator, ActionController::Base] unless defined?(INCLUDEES)

  def lcars_box(name,opts={})
    box = Lcars::Box.new name, opts
    INCLUDEES.each do |cls|
      #cls.send! :include, box.module
    end
    box
  end
end
