# load this file in Spork.prefork block to properly setup the rails application

raise "where the fuck is spork?" unless defined?(Spork)

# must load simplecov before all application code
require 'simplecov'

require 'rails/application'

# keep devise from preloading User model, see https://gist.github.com/1344547
Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

# Prevent main application to eager_load in the prefork block (do not load files in autoload_paths)
# see http://my.rails-royce.org/2012/01/14/reloading-models-in-rails-3-1-when-usign-spork-and-cache_classes-true/
Spork.trap_method(Rails::Application, :eager_load!)

require File.dirname(__FILE__) + "/environment"

# preload all engines and railties we want
Rails.application.railties.all do |r|
  # Devise controllers inherit from _our_ ApplicationController
  # so does InheritedResources::Base
  unless r.is_a?(Devise::Engine) or r.is_a?(InheritedResources::Railtie)
    r.eager_load!
  end
end

