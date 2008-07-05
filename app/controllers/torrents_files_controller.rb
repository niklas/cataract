class TorrentsFilesController < ApplicationController
  helper :torrents

  before_filter :fetch_torrent

  def show
    respond_to do |wants|
      wants.js
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
        @dir = Directory.find(params[:content][:path])
        target = @dir.path
        @torrent.move_content_to target
        flash[:notice] = "Torrent will be moved to #{target}"
        render_details_for @torrent
      end
    end
  end

  private
  def fetch_torrent
    @torrent = Torrent.find(params[:torrent_id])
  end
end
