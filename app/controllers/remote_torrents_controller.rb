class RemoteTorrentsController < ApplicationController
  respond_to :json

  def index
    collection.each { |t| t.directory = directory }
    render json: collection
  end

  protected
  def collection
    @remote_torrents ||= search_torrents
  end

  def directory
    @directory ||= Directory.find(params[:directory_id])
  end

  def search_torrents
    result = SearchTorrentsOnline.call filter: directory.filter, logger: Rails.logger
    if result.success?
      result.torrents
    else
      raise result.message
    end
  end
end
