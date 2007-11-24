class WatchesController < ApplicationController
  # TODO make resourceful
  before_filter :create_log
  helper :torrents

  def index
    respond_to do |wants|
      wants.js  { render :partial => 'watchlist' }
      wants.xml { render :layout => false }
      wants.html { render :action => 'list', :controller => 'torrents' }
    end
  end

  def create
    @torrent = Torrent.find params[:torrent_id]
    if current_user.watch(@torrent)
      render_info("Added '#{@torrent.short_title}' to watchlist")
      render_details_for @torrent
    else
      render_warning("Already watching '#{@torrent.short_title}'")
    end
  end
  def destroy
    @watching = Watching.find params[:id]
    if @watching.destroy
      render_info("Removed '#{@torrent.short_title}' from watchlist")
      render_details_for @torrent
    else
      render_error("Could not unwatch - hrm...")
    end
  end

end
