class TorrentsController < ApplicationController
  before_filter :login_required
  before_filter :set_default_page_title

  def index
    redirect_to :action => :running
  end

  def list
    @torrents = Torrent.find(:all,:order => 'filename')
  end

  # Torrent groups
  def running
    @active_group = "running"
    @torrents = Torrent.running
  end

  def paused
    @active_group = "paused"
    @torrents = Torrent.paused
  end

  def history
    @active_group = "history"
    @torrents = Torrent.archived
  end

  def invalid
    @active_group = "invalid"
    @torrents = Torrent.invalid_status
  end

  # actions
  def stop
    @torrent = Torrent.find(params[:id])
    @torrent.archive
    if @torrent.save
      @notice = @torrent.short_title + " was moved to history"
      render :partial => 'remove', :object => @torrent
    end
  end

  def pause
    @torrent = Torrent.find(params[:id])
    @torrent.pause
    if @torrent.save
      @notice = @torrent.short_title + " has been paused"
      render :partial => 'remove', :object => @torrent
    end
  end

  def start
    @torrent = Torrent.find(params[:id])
    @torrent.start
    if @torrent.save
      @notice = @torrent.short_title + " has been started for transfer"
      render :partial => 'remove', :object => @torrent
    end
  end

  def show
    @torrent = Torrent.find(params[:id])
    render :layout => false
  end

  def edit
  end

  def check_all
    errors = ''
    Torrent.find_all.each do |t|
      unless t.save
        errors += "destroyed #{t.id}<br />" if t.destroy
      end
    end
    render :text => errors
  end

  def watch
    @torrent = Torrent.find(params[:id])
    current_user.watch(@torrent)
    watchlist
  end

  def unwatch
    current_user.unwatch(params[:id])
    watchlist
  end

  def watchlist
    render :partial => 'watchlist'
  end

  def summary
    render :layout => false
  end

  private
  def set_default_page_title
    @page_title = 'torrents'
  end
end
