class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  before_filter :login_from_cookie
  helper :notification
  helper :lcars

  
  protected
  def find_torrent_by_id
    @torrent = Torrent.find(params[:id]) if params[:id]
    true
  end
  def render_error(msg='Random Error Message')
    render_log(msg,:error)
  end
  def render_warn(msg='Random Warning Message')
    render_log(msg,:warn)
  end
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
    render_log
    render_info
    render_warn
    render_error
    true
  end
end
