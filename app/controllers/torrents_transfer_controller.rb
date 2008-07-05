class TorrentsTransferController < ApplicationController
  before_filter :fetch_torrent
  # start
  def create
    @torrent.start!
    respond_to do |wants|
      wants.js do
        if @torrent.errors.empty?
          render_notice @torrent.short_title + " has been started for transfer"
          render :template => '/torrents/show'
        else
          render_error "Error while starting: #{@torrent.errors.full_messages.join(',')}"
        end
      end
    end
  end

  # stop
  def destroy
    @torrent.stop!
    respond_to do |wants|
      wants.js do
        if @torrent.errors.empty?
          render_notice @torrent.short_title + " was moved to history"
          render :template => '/torrents/show'
        else
          render_error "Error while stopping: #{@torrent.errors.full_messages.join(',')}"
        end
      end
    end
  end

  # pause
  def pause
    @torrent.pause!
    respond_to do |wants|
      wants.js do
        if @torrent.errors.empty?
          render_notice @torrent.short_title + " has been paused"
          render :template => '/torrents/show'
        else
          render_error "Error while pausing: #{@torrent.errors.full_messages.join(',')}"
        end
      end
    end
  end


  private
  def fetch_torrent
    @torrent = Torrent.find params[:torrent_id]
  end
end
