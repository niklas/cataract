class AccountController < ApplicationController
  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if current_user
      redirect_back_or_default(:controller => '/torrents')
      flash[:notice] = "Logged in successfully"
    end
  end

  def signup
    redirect_to :action => 'login' if Settings.signup_forbidden
    @user = User.new(params[:user])
    return unless request.post?
    if @user.save
      self.current_user = User.find_by_login(@user.login)
      flash[:notice] = "Thanks for signing up!"
      redirect_to :action => 'user_settings', :controller => 'config'
    end
  end
  
  def logout
    self.current_user = nil
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end
end
