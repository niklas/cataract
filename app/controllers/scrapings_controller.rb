require_dependency 'scraper'
class ScrapingsController < ApplicationController
  def new
  end

  def create
    @scraping = Scraper.scrape params[:url]
    if @scraping.success?
      render json: @scraping.messages
    else
      render json: @scraping.messages, status: 406
    end
  end
end
