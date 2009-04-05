class TorrentsFilesController < ApplicationController
  layout false
  helper :torrents_files

  before_filter :fetch_torrent

  def show
    respond_to do |wants|
      wants.js
    end
  end

  def edit
    @series_dir = Directory.for_series
    respond_to do |wants|
      wants.js
    end
  end

  def update
    unless (dir_id = params[:files][:directory_id]).to_i > 0
      flash[:error] = "Please specify a valid destination directory."
    else
      if @dir = Directory.find_by_id(dir_id)
        target = @dir.path_with_optional_subdir params[:files][:subdir]
        if @torrent.move_content_to(target) and @torrent.errors.empty?
          flash[:notice] = "Torrent will be moved to #{target}"
          render :template => '/torrents/show'
          return
        else
          flash[:error] = "Could not move the torrent's content: #{@torrent.errors.on(:files)}"
        end
      else
        flash[:error] = "No Directory found with id=#{dir_id}"
      end
    end
    render :action => 'edit'
  end

  def destroy
    bytes = @torrent.content_bytes_on_disk
    if @torrent.delete_content!
      flash[:notice] = "Deleted Content for #{@torrent.short_title} (#{@template.human_bytes bytes})"
    else
      flash[:error] = "Could not delete content: #{@torrent.errors.on(:files)}"
    end
    render :template => '/torrents/show'
  end

  private
  def fetch_torrent
    @torrent = Torrent.find(params[:torrent_id])
  end
end
