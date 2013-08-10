class ScrapesController < ApplicationController
  def new
    render js: %Q~alert("going to fetch #{bookmarklet_params[:url]}");~
  end

  private
  def bookmarklet_params
    @bookmarklet_params ||= {}.with_indifferent_access.tap do |b|
      b[:url] = params[:u]
      b[:title] = params[:t]
      b[:selection] = params[:selection]
    end
  end
end
