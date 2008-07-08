class TorrentsController < ApplicationController
  before_filter :set_default_page_title
  before_filter :find_torrent_by_id, :only => [:show, :start, :pause, :stop, :fetch, :delete_content, :set_torrent_tag_list]
  before_filter :create_log
  helper :tags

  attr_accessor :offline

  def index
    @torrents = Torrent.recent
    #@torrents ||= Torrent.running.newest_first
    respond_to do |wants|
      wants.html { render :action => 'index' }
      wants.js { render_list_of(@torrents)}
    end
  end

  def watched
    @torrents = current_user.torrents
    render :action => 'list'
  end

  # actions
  def show
    respond_to do |wants|
      wants.js 
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


  def new
    @torrent = Torrent.new
    respond_to do |want|
      want.js
    end
  end

  def probe
    respond_to do |wants|
      wants.js do
        @torrent = Torrent.new(:url => params[:url].strip)
        render
      end
    end
  end

  # create torrent
  # TODO: other ways than fetching with url
  def create
    @torrent = Torrent.create(params[:torrent])
    if @torrent.save
      if params[:commit] == "Fetch"
        @torrent.fetch_and_start!
        current_user.watch(@torrent)
      end
      respond_to do |wants|
        wants.js  { render :action => 'show' }
        wants.html  { render :action => 'show' }
      end
    else
      respond_to do |wants|
        wants.js  { render :action => 'new' }
        wants.html  { render :action => 'new' }
      end
    end
  end

  def fetch
    begin
      @torrent.fetch!
      current_user.watch(@torrent)
      log_notification("Torrent fetched: #{@torrent.short_title}")
    rescue => e
      log_error(e.to_s)
    end
    render :action => 'show'
  end

  def search
    @term = params[:term]
    if @term.is_a?(String) && !@term.empty? && URI.regexp.match(@term)
      @torrent = Torrent.new(:url => @term)
      probe
      return
    end
    #@searched_tags = Tag.parse(params[:tags])
    if !@term.blank?
      @torrents = Torrent.include_everything.newest_first.search(@term)
      flash[:reply] = "searched for #{@term}"
    else
      @torrents = Torrent.newest_first.running
      flash[:reply]= ''
    end
    respond_to do |wants|
      wants.js {
        render :update do |page|
          page.update_main :content => {:partial => 'list', :object => @torrents}
        end
      }
      wants.html {
        render :action => 'list'
      }
    end
  end

  def set_torrent_tag_list
    @torrent.tag_list = params[:value]
    @torrent.save
    render :update do |page|
      page["torrent_tag_list_#{@torrent.id}_in_place_editor"].replace_html @torrent.tag_list.to_s
      page[:tag_cloud].replace_html render(:partial => 'tag_cloud')
    end
  end

  def destroy
    @torrent = Torrent.find params[:id]
    @torrent.destroy
    log_notification("Removed Torrent '#{@torrent.short_title}'")
    respond_to do |wants|
      wants.html { redirect_to :action => 'index' }
      wants.js
    end
  end

  private
  def set_default_page_title
    @searched_tags ||= []
    @page_title = 'torrents'
  end
end
