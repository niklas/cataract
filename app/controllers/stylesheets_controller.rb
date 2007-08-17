class StylesheetsController < ApplicationController
  before_filter :set_headers
  after_filter  { |c| c.cache_page }
  session :off
  layout nil

  private
  def set_headers
    ::ActionController::Base.page_cache_extension = '.css'
    headers['Content-Type'] = 'text/css; charset=utf-8'
  end
end
