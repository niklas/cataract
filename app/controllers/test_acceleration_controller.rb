# This Controller provides fast sign in for all the cucumber features. 
#
# !! In production, this must be considered a security risk!! 
#
# It should not be deployed (or deleted before running production code).
#
class TestAccelerationController < ApplicationController
  skip_authorization_check only: :sign_in
  skip_before_filter :authenticate_user!
  before_filter :only_in_test_env

  def sign_in
    if user = User.find_by_email(params[:email])
      super user
    end
    if user_signed_in?
      render :text => 'success'
    else
      render :text => 'fail'
    end
  end

  private

  def only_in_test_env
    unless Rails.env.test?
      flash[:apocalypse] = "only available in testmode"
    end
  end
end
