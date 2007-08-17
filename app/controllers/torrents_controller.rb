class TorrentsController < ApplicationController
  before_filter :login_required
  before_filter :set_default_page_title

  def index
    redirect_to :action => 'list', :state => 'running'
  end

  def list
    @status = (params[:status] || :running).to_sym
    @torrents = Torrent.find_in_state(@status, :order => 'created_at desc')
    forget_all
    memorize_preview(@torrents)
  end

  def refresh
    @previewed = Torrent.find_collection(session[:previewed_torrents])
    @shown = Torrent.find_collection(session[:shown_torrents])
    respond_to do |wants|
      wants.js 
    end
  end

  # actions
  def stop
    @torrent = Torrent.find(params[:id])
    @torrent.stop!
    if @torrent.errors.empty?
      flash[:notice] = @torrent.short_title + " was moved to history"
      forget(@torrent)
      render :partial => 'remove', :object => @torrent
    else
      render :update do |page|
        page.notification("Error while stopping: #{@torrent.errors.full_messages.join(',')}")
      end
    end
  end

  def pause
    @torrent = Torrent.find(params[:id])
    @torrent.pause!
    if @torrent.save!
      flash[:notice] = @torrent.short_title + " has been paused"
      forget(@torrent)
      render :partial => 'remove', :object => @torrent
    end
  end

  def start
    @torrent = Torrent.find(params[:id])
    @torrent.start!
    if @torrent.save!
      flash[:notice] = @torrent.short_title + " has been started for transfer"
      forget(@torrent)
      render :partial => 'remove', :object => @torrent
    end
  end

  def show
    @torrent = Torrent.find(params[:id])
    respond_to do |want|
      want.js 
    end
    mark_shown(@torrent)
  end

  def preview
    @torrent = Torrent.find(params[:id])

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

  def watch
    @torrent = Torrent.find(params[:id])
    if current_user.watch(@torrent)
      render :update do |page|
        page.insert_html :top, :watchlist, render(:partial => 'watchlist_item', :object => @torrent)
        page.notification("Added '#{@torrent.short_title}' to watchlist")
      end
    else
      render :update do |page|
        page.notification("Already watching '#{@torrent.short_title}'")
      end
    end
  end

  def unwatch
    current_user.unwatch(params[:id])
    @torrent = Torrent.find(params[:id])
    respond_to do |wants|
      wants.js do
        render :update do |page|
          page.remove("watched_torrent_#{@torrent.id}")
          page.notification("Removed '#{@torrent.short_title}' from watchlist")
        end
      end
    end
  end

  def watchlist
    respond_to do |wants|
      wants.js  { render :partial => 'watchlist' }
      wants.xml { render :layout => false }
    end
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
      
      if @torrent.fetchable?
        render :partial => 'probe_success'
      else
        render :partial => 'probe_fail'
      end
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
  def fetch_by_url
    @torrent = Torrent.new(:url => params[:url])
    @torrent.status = :remote
    unless @torrent.save
      render :partial => 'probe_fail'
      return
    end
    if @torrent.fetch_and_start!
      current_user.watch(@torrent)
      respond_to do |wants|
        wants.js do
          render :update do |page|
            page[:reply].update ""
            page.insert_html :top, :content, 
              render(:partial => 'preview', :object => @torrent)
            page.notification("Torrent fetched: #{@torrent.short_title}")
          end
        end
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
    if @term.is_a?(String) && !@term.empty? 
      if URI.regexp.match(@term)
        @torrent = Torrent.new(:url => @term)
        probe
        return
      else
        @torrents = Torrent.find_by_term @term
        @reply = "searched for #{@term}"
      end
    else
      @torrents = Torrent.find_in_state(:running, :order => 'created_at desc')
      @reply = ''
    end
    forget_all
    memorize_preview(@torrents)
    respond_to do |wants|
      wants.js {
        render :update do |page|
          page[:content].update(render('/torrents/list'))
          page[:reply].update @reply
        end
      }
    end
  end

  def delete_content
    @torrent = Torrent.find(params[:id])
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
    @torrent = Torrent.find(params[:id])
    @torrent.tag_list = params[:value]
    @torrent.save
    render :text => @torrent.tag_list.to_s
  end

  private
  def set_default_page_title
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
end
