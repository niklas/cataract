class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include Userstamp

  before_filter :setup_lcars
  #before_filter :login_from_cookie
  before_filter :login_required
  helper :all

  layout 'torrents'

  rescue_from 'Exception', :with => :render_lcars_error

  after_update_page :prepare_flash_messages
  after_update_page :render_pending_logs
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

  def render_lcars_error(exception)
    logger.debug("Cought Exception: #{exception.class}:#{exception.message}\nTrace:\n#{exception.clean_backtrace.join("\n")}")
    @exception = exception
    respond_to do |wants|
      wants.css do
        render :text => @exception.inspect.to_s
      end
      wants.html do
        render :partial => '/shared/exception', :object => exception, :layout => 'torrents'
      end
      wants.js do
        render_update do |page|
          page.insert_html :bottom, 'body', render_error(
            :title => (exception.message),
            :content => content_tag(:h3,exception.message) + content_tag(:pre, h(exception.clean_backtrace.join("\n   "))),
            :buttons => [
              link_to("Back", :back),
              link_to_function("Close") do |page|
                page['error'].remove
              end
            ],
            :theme => 'error'
          )
        end
      end
    end
    #response.headers['Status'] = interpret_status(500)
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

  def setup_lcars
    lcars_box :helm, :kind => 'se', :theme => 'primary', :title => 'Helm'
    lcars_box :main, :kind => 'nw', :theme => 'secondary', 
      :title => :torrent_search, 
      :buttons => :torrent_menu_links,
      :content => lambda {{:partial => '/torrents/list', :object => @torrents }}
    lcars_box :engineering, :kind => 'nw',  :theme => 'ancillary',
      :title => lambda { (logged_in? ? "Logged in as #{current_user.login}" : 'Klingon Attacking') },
      :buttons => :engineering_buttons,
      :content => lambda {{:partial => '/log_entries/list', :object => (@logs || @log_entries || LogEntry.last.all)}}
    lcars_box :single, :kind => 'nw'
    lcars_box :tiny, :kind => 'nes'
    lcars_box :error, :kind => 'nw'
  end
end
