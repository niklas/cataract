require_dependency 'torrent_fetcher'
class ScrapingsController < ApplicationController
  include RailsBookmarklet
  def new
    @url = params[:url]
    render_bookmarklet 'new_scraping', 'new'
  end

  def create
    @scraping = TorrentFetcher.new
    if @scraping.process params[:url]
      Rails.logger.debug { "fetched successfully: #{@scraping.messages.inspect}" }
      render json: { messages: @scraping.messages }
    else
      Rails.logger.debug { "fetching failed: #{@scraping.messages.inspect}" }
      render json: { messages: @scraping.messages }, status: 406
    end
  end
end
