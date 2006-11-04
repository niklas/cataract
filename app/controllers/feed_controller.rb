class FeedController < ApplicationController
  layout 'torrents'
  helper :torrents
  before_filter :login_required
  in_place_edit_for :filter, :expression
  in_place_edit_for :feed, :url
  in_place_edit_for :feed, :title
  def index
    @feeds = Feed.find(:all, :order => 'created_at desc')
  end

  def new
    @feed = Feed.new
  end

  def probe
    @feed = Feed.new :url => params[:url]
    if @feed.fetchable?
      render :update do |page|
        page[:feed_title].value = @feed.title
        page[:feed_url].class = 'found'
        page[:add_button].disabled = false
        page[:add_button].value = 'add'
        page[:error].update '' 
      end
    else
      render :update do |page|
        page[:feed_url].class = 'not_found'
        page[:add_button].disabled = true
        page[:add_button].value = 'not found'
        page[:error].update nice_error_messages_for :feed
        page[:feed_title].value = '' 
      end
    end
  end

  def create
    @feed = Feed.new(params[:feed])
    if @feed.save
      render :update do | page|
        page[:feed_form].remove
        page.insert_html :top, :feed_list, render(:partial => 'feed_list_item', :object => @feed )
      end
    else
      render :update do |page|
        page[:feed_form].update render(:partial => 'form')
      end
    end
  end

  def show
    @feed = Feed.find params[:id]
  end

  def delete
    @feed = Feed.find params[:id]
    @feed.destroy
    redirect_to :action => 'index'
  end

  def new_filter
    @filter = Filter.create :expression => 'Click to Edit', :feed_id => params[:feed]
  end

  def delete_filter
    @filter = Filter.find params[:id]
    @filter.destroy
  end

  def feed_items
    @feed = Feed.find params[:id], :include => 'filters'
  end

  def sset_filter_expression
    @filter = Filter.find params[:id]
    @filter.update_attribute(:value, params[:value])
  end

end
