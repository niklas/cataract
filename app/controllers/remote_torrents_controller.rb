class RemoteTorrentsController < ApplicationController
  respond_to :json

  before_action :assign_directories, if: :directory?, only: :index

  def index
    render json: collection
  end

  protected
  def collection
    @remote_torrents ||= search_torrents
  end

  def directory?
    params[:directory_id]
  end

  def directory
    @directory ||= Directory.find(params[:directory_id])
  end

  def feed?
    params[:feed_id]
  end

  def feed
    @feed ||= Feed.find(params[:feed_id])
  end

  def search_torrents
    result = search_torrents_interactor
    if result.success?
      result.torrents
    else
      raise result.message
    end
  end

  def assign_directories
    collection.each { |t| t.directory = directory }
  end

  def search_torrents_interactor
    if directory?
      SearchTorrentsOnline.call filter: directory.filter, logger: Rails.logger
    elsif feed?
      FetchTorrentsFromRSS.call feed: feed
    else
      raise 'must specify directory or feed'
    end
  end
end
