class GreetingsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => :landing
  def landing
    if user_signed_in?
      redirect_to torrents_path
    end
  end

end
