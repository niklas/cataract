class ConfigController < ApplicationController
  before_filter :login_required
  layout "torrents"

  helper :torrents

  def settings
  end

  def save_setting
    var = params[:var]
    value = params[:value]
    if var && value
      Settings[var] = value
    end
    render :text => Settings[var]
  end

  def user_settings
    if request.post?
      current_user.update_attributes(params[:user])
      flash[:notice] = "Your settings were saved." if current_user.save
      flash[:notice] += "<br/>A test message was sent to <b>#{current_user.jabber}</b>." if current_user.sent_test_message
    end
    @user = User.find(current_user.id)
  end
end
