class FeedController < ApplicationController
  layout 'torrents'
  def index
    @feeds = Feed.find(:all, :order => 'created_at desc')
  end

  def new
  end
end
