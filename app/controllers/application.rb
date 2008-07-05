class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  before_filter :setup_lcars
  #before_filter :login_from_cookie
  before_filter :login_required
  helper :all

  layout 'torrents'

  rescue_from 'Exception', :with => :render_lcars_error

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
        render :template => '/shared/error'
      end
      wants.js do
        render :update do |page|
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

  # FIXME update more than one (use render_update - does not work for errors yet...)
  def update_lcars(target='helm')
    render :update do |page|
      foo = page.lcars.by_id(target)
      yield(foo,page)
    end
  end

  # This is called whenever to call to #render was made.
  # It appends the log_entries annd calls multiple render actions (see #render_update).
  def default_render
    if request.xhr?
      render :update do |page|
        unless @to_render.empty?
          @to_render.each do |task|
            task.call page
          end
        end
        append_log_to(page)
      end
    else
      render
    end
  end
  # call in your action
  # render_update do |page|
  #   page.update 'foo', 'barz'
  # end
  def render_update &blk
    @to_render ||= []
    @to_render << blk
  end
  def render_details_for(torrent)
    render_update do |page|
      page.replace :helm, Hobo::Dryml.render_tag(@template,'details', :with => torrent)
    end
  end
  def render_list_of(torrents)
    render_update do |page|
      page.replace :main, Hobo::Dryml.render_tag(@template, 'list_of_torrents', :with => torrents)
    end
  end

  def find_torrent_by_id
    @torrent = Torrent.find(params[:id]) if params[:id]
    true
  end
  def render_error(msg='Random Error Message')
    render_log(msg,:error)
  end
  def render_warning(msg='Random Warning Message')
    render_log(msg,:warn)
  end
  alias render_warn render_warning
  def render_info(msg='Random Info Message')
    render_log(msg,:info)
  end
  def render_notice(msg='Random Notice Message')
    render_log(msg,:info)
  end
  def render_log(msg='Random Log Message',level=:log)
    return true
    @logs << LogEntry.new(msg,level)
  end
  def create_log
    @logs = []
    true
  end
  def h(stringy)
    CGI.escapeHTML(stringy)
  end

  def setup_lcars
    define_box :helm, :kind => 'se', :theme => 'primary'
    define_box :main, :kind => 'nw', :theme => 'secondary'
    define_box :engineering, :kind => 'nw',  :theme => 'ancillary'
    define_box :single, :kind => 'nw'
    define_box :tiny, :kind => 'nes'
    define_box :error, :kind => 'nw'
  end
end
