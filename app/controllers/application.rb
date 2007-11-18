class ApplicationController < ActionController::Base
  #include AuthenticatedSystem
  before_filter :login_from_cookie
  before_filter :login_required
  helper :notification
  helper :lcars

  hobo_controller

  protected
  # hobo hook
  def access_denied(user_model=nil)
    redirect_to :controller => 'account', :action => 'login'
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
    @logs << LogEntry.new(msg,level)
  end
  def create_log
    @logs = []
    true
  end
end
