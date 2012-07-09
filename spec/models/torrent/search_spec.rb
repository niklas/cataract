require 'spec_helper'

describe Torrent::Search do
  def s(args={})
    described_class.new(args)
  end

  context 'attributes' do

    it "detects status" do
      s(status: "running").present_attributes.should be_matching('status' => 'running')
    end

    it "translates status" do
      I18n.with_locale :en do
        s(status: "running").translated_criteria.should be_matching('status' => 'running torrents')
      end
    end

  end


  context 'title' do

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

    it "should show directory" do
      dir = create :directory, name: 'Hidden Place'
      s(directory_id: dir.id).title.should ==
        'all torrents in "Hidden Place"'
    end

  end

end
