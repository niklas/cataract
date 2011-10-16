require File.dirname(__FILE__) + '/../spec_helper'

describe Feed do
  before(:each) do
    @feed = Feed.new
  end

  it "should not be valid" do
    @feed.should_not be_valid
  end

  it 'needs a title and url to be valid' do
    @feed.title = "Some title"
    @feed.should_not be_valid
    @feed.url = "http://why.should.you/care"
    @feed.should be_valid
  end
end

describe "The Comic Feed" do
  before(:each) do
    pending "use factories for feeds"
    @comic_feed = feeds(:comic_feed)
  end

  it do
    @comic_feed.should have(4).torrents
  end

  it do
    @comic_feed.should have(3).filters
  end

  it 'should filter out only the non-hd simpsons and southpark episode(s)' do
    @comic_feed.should have(2).filtered_torrents
    @comic_feed.filtered_torrents.should include(torrents(:simpsons_23_5))
    @comic_feed.filtered_torrents.should include(torrents(:southpark_chef))
  end
end

