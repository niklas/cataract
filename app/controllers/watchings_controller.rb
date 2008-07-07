class WatchingsController < ApplicationController
  # TODO make resourceful
  before_filter :create_log
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
        if current_user.watch(@torrent)
          log_info("Added '#{@torrent.short_title}' to watchlist")
        else
          log_warning("Already watching '#{@torrent.short_title}'")
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
        if @watching.destroy
          log_info("Removed '#{@torrent.short_title}' from watchlist")
        else
          log_error("Could not unwatch - hrm...")
        end
        render :template => '/torrents/update_buttons'
      end
    end
  end

end
