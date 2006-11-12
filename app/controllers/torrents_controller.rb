class TorrentsController < ApplicationController
  before_filter :login_required
  before_filter :set_default_page_title

  def index
    redirect_to :action => :running
  end

  def list
    @status = (params[:status] || :running).to_sym
    @torrents = Torrent.find_in_state(:all,@status)
  end

  # actions
  def stop
    @torrent = Torrent.find(params[:id])
    @torrent.archive!
    if @torrent.save!
      @notice = @torrent.short_title + " was moved to history"
      render :partial => 'remove', :object => @torrent
    end
  end

  def pause
    @torrent = Torrent.find(params[:id])
    @torrent.pause!
    if @torrent.save!
      @notice = @torrent.short_title + " has been paused"
      render :partial => 'remove', :object => @torrent
    end
  end

  def start
    @torrent = Torrent.find(params[:id])
    @torrent.start!
    if @torrent.save!
      @notice = @torrent.short_title + " has been started for transfer"
      render :partial => 'remove', :object => @torrent
    end
  end

  def show
    @torrent = Torrent.find(params[:id])

    respond_to do |want|
      want.js
    end
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

  def new
    @torrent = Torrent.new
    respond_to do |want|
      want.js
    end
  end

  def probe
    if params[:url] and !params[:url].empty?
      @torrent = Torrent.new(:url => params[:url].strip)
      
      if @torrent.fetchable?
        render :partial => 'probe_success'
      else
        render :partial => 'probe_fail'
      end
    else
      render :update do |page|
        page[:checked_url].update "Please enter an URL"
      end
    end
  end

  def create
    @torrent = Torrent.new(params[:torrent])
    if @torrent.fetch!
      current_user.watch(@torrent)
      render :update do |page|
        page[:checked_url].update "Torrent fetched: #{@torrent.filename}"
      end
    else
      render :partial => 'probe_fail'
    end
  end

  def fetch
    @torrent = Torrent.find(params[:id])
    begin
      @torrent.fetch!
      current_user.watch(@torrent)
      render :update do |page|
        page[:notice].update "Torrent fetched: #{@torrent.filename}"
      end
    rescue => e
      render :update do |page|
        page[:notice].update e.to_s
      end
    end
  end

  def search
    @term = params[:term]
    @torrents = Torrent.search(@term)
    render :action => 'list', :layout => false, :locals => { :fields => %w(title state)}
  end

  private
  def set_default_page_title
    @page_title = 'torrents'
  end
end
