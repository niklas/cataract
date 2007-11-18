class WatchesController < ApplicationController
  before_filter :find_torrent_by_id, :only => [:create, :destroy]
  before_filter :create_log
  helper :torrents

  def default_render
    render :update do |page|
      page.replace :helm, Hobo::Dryml.render_tag(@template,'details', :with => @torrent) if @torrent
      append_log_to(page)
    end
  end
  def index
    respond_to do |wants|
      wants.js  { render :partial => 'watchlist' }
      wants.xml { render :layout => false }
    end
  end

  def create
    if current_user.watch(@torrent)
      render_info("Added '#{@torrent.short_title}' to watchlist")
    else
      render_warning("Already watching '#{@torrent.short_title}'")
    end
  end
  def destroy
    current_user.unwatch(@torrent.id)
    render_info("Removed '#{@torrent.short_title}' from watchlist")
  end
end
