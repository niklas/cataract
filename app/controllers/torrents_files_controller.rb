class TorrentsFilesController < ApplicationController
  layout false
  helper :torrents

  before_filter :fetch_torrent

  def show
    respond_to do |wants|
      wants.js
    end
  end

  def edit
    respond_to do |wants|
      wants.js
    end
  end

  def update
    respond_to do |wants|
      wants.js do
        @dir = Directory.find(params[:content][:path])
        target = @dir.path_with_optional_subdir params[:content][:subdir]
        logger.debug "Torrent will be moved to #{target}"
        @torrent.move_content_to target
        if @torrent.errors.empty?
          flash[:notice] = "Torrent will be moved to #{target}"
          render :template => '/torrents/show'
        else
          render :action => 'edit'
        end
      end
    end
  end

  def create
    raise "Please start the torrent to create its files"
  end

  private
  def fetch_torrent
    @torrent = Torrent.find(params[:torrent_id])
  end
end
