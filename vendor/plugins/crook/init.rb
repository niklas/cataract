# Include hook code here
ActionView::Base.class_eval do
  include Crook::I18nHelper
end
