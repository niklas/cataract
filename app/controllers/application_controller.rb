class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  # TODO cells ore similar
  helper :all

  include EmberRailsFlash::FlashInHeader

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = translate('message.access_denied')
    respond_to do |denied|
      denied.html { redirect_to root_url }
      denied.js   { render 'denied' }
    end
  end

  protected
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
    params.slice(:status, :terms, :page, :per).merge( params[:torrent_search] || {})
  end

  def clear_transfer_cache
    Torrent.remote.clear_caches!
  end
end
