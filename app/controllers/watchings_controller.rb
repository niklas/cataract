class WatchingsController < ApplicationController
  before_filter :fetch_user
  before_filter :authorized_user_for_watching
  helper :torrents
  layout false

  def index
    respond_to do |wants|
      wants.js  { render :partial => 'watchlist' }
      wants.xml { render :layout => false }
      wants.html { render :action => 'list', :controller => 'torrents' }
    end
  end

  def create
    respond_to do |wants|
      wants.js do
        @torrent = Torrent.find params[:torrent_id]
        if @user.watch(@torrent)
          flash[:notice] =("Added '#{@torrent.short_title}' to watchlist")
        else
          flash[:warning] =("Already watching '#{@torrent.short_title}'")
        end
        render :template => '/torrents/update_buttons'
      end
    end
  end
  def destroy
    respond_to do |wants|
      wants.js do
        @watching = Watching.find params[:id]
        @torrent = @watching.torrent
        if @user.unwatch(@torrent)
          flash[:notice] =("Removed '#{@torrent.short_title}' from watchlist")
        else
          flash[:error] =("Could not unwatch - hrm...")
        end
        render :template => '/torrents/update_buttons'
      end
    end
  end

  private
  def authorized_user_for_watching
    unless @user == current_user
      flash[:error] = "Watch yourself!"
      false
    else
      true
    end
  end

  def fetch_user
    @user = User.find(params[:user_id])
  end

end
