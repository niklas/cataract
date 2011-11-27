class TorrentsController < InheritedResources::Base
  attr_accessor :offline

  has_widgets do |root|
    root << widget(:torrents)
    root << widget(:torrents_header)
    root << widget(:torrents_navigation)
    root << widget(:torrent)
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
        @torrent ||= Torrent.new(:url => params[:url].strip)
      end
    end
  end

  # create torrent
  # TODO: other ways than fetching with url
  def create
    raise NotImplementedError, 'move to model'
    @torrent = Torrent.create(params[:torrent])
    if @torrent.save
      if params[:commit] == "Fetch"
        @torrent.fetch_and_start!
        current_user.watch(@torrent)
      end
      respond_to do |wants|
        wants.js  do
          render_update do |page|
            page[:torrent_search].reset
          end
          render :action => 'show'
        end
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
end
