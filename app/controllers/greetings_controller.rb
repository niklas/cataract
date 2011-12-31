class GreetingsController < ApplicationController
  def dashboard
  end

  skip_before_filter :authenticate_user!, :only => :landing
  def landing
    if user_signed_in?
      redirect_to dashboard_path
    end
  end

end
