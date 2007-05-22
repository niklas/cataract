class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :notification
end
