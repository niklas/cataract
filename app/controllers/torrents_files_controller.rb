class TorrentsFilesController < ApplicationController
  helper :torrents

  before_filter :fetch_torrent

  def show
    respond_to do |wants|
      wants.js do
        render :update do |page|
          page["torrent_#{@torrent.id}"].replace_html :partial => 'list', :object => @torrent.files_hierarchy
        end
      end
    end
  end

  def edit
    respond_to do |wants|
      wants.js do
        render :update do |page|
          page["torrent_#{@torrent.id}"].replace_html :partial => 'move', :object => @torrent
        end
      end
    end
  end

  def update
    respond_to do |wants|
      wants.js do
        render :update do |page|
          page["torrent_#{@torrent.id}"].replace_html params.inspect.to_s
        end
      end
    end
  end

  private
  def fetch_torrent
    @torrent = Torrent.find(params[:torrent_id])
  end
end
