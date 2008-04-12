class TorrentsFilesController < ApplicationController
  helper :torrents

  before_filter :fetch_torrent

  def show
    respond_to do |wants|
      wants.js do
        render :update do |page|
          page["torrent_#{@torrent.id}"].replace_html :partial => 'list', :object => @torrent.metainfo.files
        end
      end
    end
  end

  def update
  end

  private
  def fetch_torrent
    @torrent = Torrent.find(params[:torrent_id])
  end
end
