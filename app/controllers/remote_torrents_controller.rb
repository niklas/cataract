class RemoteTorrentsController < ApplicationController
  respond_to :json

  def index
    @remote_torrents = collection
  end

  protected
  def collection
    []
  end
end
