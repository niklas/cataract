class WatchesController < ApplicationController
  before_filter :find_torrent_by_id, :only => [:create, :destroy]
  before_filter :create_log
  def index
    respond_to do |wants|
      wants.js  { render :partial => 'watchlist' }
      wants.xml { render :layout => false }
    end
  end

  def create
    if current_user.watch(@torrent)
      render_notice("Added '#{@torrent.short_title}' to watchlist")
    else
      render_notice("Already watching '#{@torrent.short_title}'")
    end

    render :update do |page|
      page.replace 'event_log', Hobo::Dryml.render_tag(@template, 'event_log', :with => @logs)
    end
  end
  def destroy
    current_user.unwatch(@torrent.id)
    respond_to do |wants|
      wants.js do
        render :update do |page|
          render_notice("Removed '#{@torrent.short_title}' from watchlist")
          page.replace 'event_log', Hobo::Dryml.render_tag(@template, 'event_log', :with => @logs)
        end
      end
    end
  end
end
