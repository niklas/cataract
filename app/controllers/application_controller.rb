class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  # TODO cells ore similar
  helper :all

  include EmberRailsFlash::FlashInHeader

  rescue_from CanCan::AccessDenied do |exception|
    flash.now[:alert] = translate('message.access_denied')
    respond_to do |denied|
      denied.html { redirect_to root_url }
      denied.json   { render json: {}, status: 403 }
      denied.js   { render 'denied', status: 403 }
    end
  end

  rescue_from RuntimeError, Torrent::RTorrent::Error, Cataract::Application::Error do |exception|
    flash.now[:alert] = exception.message
    respond_to do |frak|
      frak.json { render json: { error: exception.message }, status: 500 }
      frak.html { render text: exception.message, status: 500 }
    end
  end

  delegate :publish, to: Cataract::Publisher

  layout :layout_by_resource


  before_action :reset_rtorrent_connection

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
    params.slice(:status, :terms, :page, :per).merge( params[:torrent_search] || {}).merge(per: 1000) # TODO paginate properly
  end

  def layout_by_resource
    if devise_controller?
      "single"
    else
      "application"
    end
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def reset_rtorrent_connection
    Torrent.reset_remote!
  end

end
