require File.dirname(__FILE__) + '/../spec_helper'

describe Feed do
  it "needs a url" do
    build(:feed, url: nil).should be_invalid
  end

  context 'without url' do
    subject { build(:feed, url: nil) }
    it { should_not be_valid }
    specify { should_not be_valid }
  end

  it "builds title from url" do
    feed = create :feed
    feed.title.should == feed.url
  end
end

