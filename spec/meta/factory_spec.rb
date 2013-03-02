require 'spec_helper'

# Test all factories for validity


describe 'Factory' do
  it "should provide some factories" do
    FactoryGirl.factories.should have_at_least(5).items
  end

  FactoryGirl.factories.each do |factory|
    next if factory.name == :torrent_with_file
    next if factory.name == :blank_directory

    describe "for #{factory.name}" do
      it "should build valid record" do
        factory.build(factory.name).should be_valid
      end
    end

  end
end

