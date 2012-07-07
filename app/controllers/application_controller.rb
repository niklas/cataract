class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  # TODO cells ore similar
  helper :all

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = translate('message.access_denied')
    respond_to do |denied|
      denied.html { redirect_to root_url }
      denied.js   { render 'denied' }
    end
  end

  # FIXME use responders
  #after_update_page :prepare_flash_messages
  #after_update_page :render_pending_logs
  def render_pending_logs(page)
    unless @logs.blank?
      @logs.each do |log_entry|
        page.insert_html :top, :log, page.context.log_entry_tag(log_entry)
      end
    end
  end

  def prepare_flash_messages(page=nil)
    @logs ||= []
    flash.each do |lvl,message|
      @logs << LogEntry.new(:message => message, :level => lvl.to_s)
    end
  end

  protected
  def render_details_for(torrent)
    # same as app/views/torrents/show.rjs
    raise "dont use that anymore, please"
  end
  def render_list_of(torrents)
    render_update do |page|
      page.update_main :content => {:partial => '/torrents/list', :object => torrents}
    end
  end

  def find_torrent_by_id
    @torrent = Torrent.find(params[:id]) if params[:id]
    true
  end
  def h(stringy)
    CGI.escapeHTML(stringy)
  end

  def directory_path(directory)
    disk_directory_path(directory.disk, directory)
  end
  helper_method :directory_path

  def search
    @search ||= Torrent.new_search(search_params)
  end
  helper_method :search

  def search_params
    params.slice(:status, :terms, :page).merge( params[:torrent_search] || {})
  end

end
