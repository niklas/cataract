class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  before_filter :login_from_cookie
  helper :notification
end
