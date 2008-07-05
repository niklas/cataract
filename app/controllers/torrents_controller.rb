class TorrentsController < ApplicationController
  before_filter :set_default_page_title
  before_filter :set_sidebar
  before_filter :find_torrent_by_id, :only => [:show, :start, :pause, :stop, :preview, :fetch, :delete_content, :set_torrent_tag_list]
  before_filter :create_log
  helper :tags

  attr_accessor :offline

  def index
    @torrents = Torrent.recent
    list
  end

  def list
    @torrents ||= Torrent.running.newest_first

    respond_to do |wants|
      wants.html { render :action => 'list' }
      wants.js { render_list_of(@torrents)}
    end
  end

  def watched
    @torrents = current_user.torrents
    render :action => 'list'
  end

  def refresh
    @previewed = Torrent.find_collection(session[:previewed_torrents])
    @shown = Torrent.find_collection(session[:shown_torrents])
    respond_to do |wants|
      wants.js 
    end
  end

  # actions
  def show
    respond_to do |wants|
      wants.js 
    end
  end

  def preview
    mark_preview(@torrent)
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


  def new
    @torrent = Torrent.new
    respond_to do |want|
      want.js
    end
  end

  def probe
    if (params[:url] and !params[:url].empty?) or @torrent
      @torrent ||= Torrent.new(:url => params[:url].strip)
      @torrent.fetchable?
      render :template => '/torrents/show'
    else
      render :update do |page|
        page[:notice].update "Please enter a URL"
        page[:notice].show
        page.visual_effect :highlight, 'notice'
      end
    end
  end

  # create torrent
  # TODO: other ways than fetching with url
  def create
    if params[:url]
      if @torrent = Torrent.fetch_and_start_by_url(params[:url])
        current_user.watch(@torrent)
        render_notice @torrent.short_title + " has been fetched"
        render :template => '/torrents/show'
      else
        render_error "Error while fetching: #{@torrent.errors.full_messages.join(',')}"
      end
    else
      render_error "Cannot fetch without url"
    end
  end

  def fetch
    begin
      @torrent.fetch!
      current_user.watch(@torrent)
      render :update do |page|
        page.notification("Torrent fetched: #{@torrent.short_title}")
      end
    rescue => e
      render :update do |page|
        page.notification(e.to_s)
      end
    end
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
    #forget_all
    #memorize_preview(@torrents)
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

  def delete_content
    if params[:delete_confirmation] == 'DELETE'
      if @torrent.delete_content! 
        @torrent.halt!
        forget(@torrent)
        render :update do |page| 
          page.notification("'#{@torrent.short_title}' has been stopped and its content deleted, max. #{@torrent.content_size} Byte freed" )
          page << render(:partial => 'remove', :object => @torrent)
        end
      else
        render :update do |page| 
          page.notification("error deleting contents: #{@torrent.errors.full_messages}")
        end
      end
    else
      render :update do |page| 
        page[:notice].update "need a confirmation to delete content"
        page[:notice].visual_effect :appear
      end
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

  def switch_sidebar
    which = params[:to]
    session[:sidebar] = which
    render :update do |page|
      page[:sidebar_switcher].replace sidebar_switcher
      page[which].replace_html render(:partial => which)
    end
  end

  private
  def set_default_page_title
    @searched_tags ||= []
    @page_title = 'torrents'
  end

  def forget(torrent)
    @removed_preview_torrent = session[:previewed_torrents].delete(torrent.id)
    @removed_shown_torrent = session[:shown_torrents].delete(torrent.id)
  end

  def forget_all
    session[:previewed_torrents] = []
    session[:shown_torrents] = []
  end

  def memorize_preview(torrents)
    session[:previewed_torrents] = torrents.collect(&:id)
  end

  def mark_shown(torrent)
    tid = torrent.id
    session[:previewed_torrents].delete(tid)
    session[:shown_torrents] << tid unless session[:shown_torrents].include?(tid)
  end

  def mark_preview(torrent)
    tid = torrent.id
    session[:shown_torrents].delete(tid)
    session[:previewed_torrents] << tid unless session[:previewed_torrents].include?(tid)
  end

  def set_sidebar
    session[:sidebar] ||= 'watchlist'
  end
end
