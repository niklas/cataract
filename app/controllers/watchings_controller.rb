class WatchingsController < ApplicationController
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
        @torrent = Torrent.find params[:torrent_id] || (params[:watching] ? params[:watching][:torrent_id] : nil)
        if @user.watch(@torrent)
          flash[:notice] =("Added '#{@torrent.short_title}' to watchlist")
        else
          flash[:warning] =("Already watching '#{@torrent.short_title}'")
        end
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
      end
    end
  end

  private
  def authorized_user_for_watching
    @user = current_user
  end

end
