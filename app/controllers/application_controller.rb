class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  # TODO cells ore similar
  helper :all

  # TODO rescue from errors

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
  def access_denied(user_model=nil)
    respond_to do |wants|
      wants.html { redirect_to login_path }
      wants.js do
        render :template => '/sessions/new'
      end
    end
  end

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

end
