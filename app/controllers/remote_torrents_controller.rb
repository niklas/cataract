class RemoteTorrentsController < ApplicationController
  respond_to :json

  def index
    result = SearchTorrentsOnline.call filter: directory.filter
    @remote_torrents = result.torrents
  end

  protected
  def collection
    []
  end

  def directory
    @directory ||= Directory.find(params[:directory_id])
  end
end
