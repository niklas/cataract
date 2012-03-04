require 'spec_helper'

describe Torrent::Search do

  context 'title' do

    def s(args={})
      described_class.new(args)
    end

    it "defaults" do
      s.title.should == 'all torrents'
    end

    it "should show status" do
      s(status: 'running').title.should == 'running torrents'
      s(status: 'archived').title.should == 'archived torrents'
    end

    it "should show terms" do
      s(terms: 'lala').title.should == 
        "all torrents containing 'lala'"
    end

    it "should show status and terms" do
      s(status: 'running', terms: 'lala').title.should == 
        "running torrents containing 'lala'"
    end

  end

end
