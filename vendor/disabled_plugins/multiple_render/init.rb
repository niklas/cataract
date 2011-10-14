require 'multiple_render'
ActionController::Base.send :include, MultipleRender::ActionController::SingletonMethods
