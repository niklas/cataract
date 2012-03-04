class TorrentsController < InheritedResources::Base
  attr_accessor :offline

  respond_to :js, :html

  before_filter :refresh!, only: :show

  def progress
    @torrents = Torrent.by_status('running')
  end

  private
  def collection
    @torrents ||= search.results
  end

  def search
    @search ||= Torrent.new_search(search_params)
  end
  helper_method :search

  def search_params
    params.slice(:status, :terms, :page).merge( params[:torrent_search] || {})
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


  def probe
    respond_to do |wants|
      wants.js do
        @torrent ||= Torrent.new(:url => params[:url].strip)
      end
    end
  end

  def fetch
    begin
      @torrent.fetch!
      current_user.watch(@torrent)
      flash[:notice] =("Torrent fetched: #{@torrent.short_title}")
    rescue => e
      flash[:error] =(e.to_s)
    end
    render :action => 'show'
  end

  def set_torrent_tag_list
    @torrent.tag_list = params[:value]
    @torrent.save
    render :update do |page|
      page["torrent_tag_list_#{@torrent.id}_in_place_editor"].replace_html @torrent.tag_list.to_s
      page[:tag_cloud].replace_html render(:partial => 'tag_cloud')
    end
  end

  def refresh!
    if request.xhr?
      resource.refresh!
    end
    true
  end
end
